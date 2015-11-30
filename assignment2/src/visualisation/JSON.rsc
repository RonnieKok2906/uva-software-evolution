module visualisation::JSON

import Prelude;

import util::Benchmark;
import DateTime;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;
import visualisation::HTML;
import util::Math;

public int before = systemTime();

public str createJSON(str projectName, PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel)
{
	bf = systemTime();

	str result = "\n{\n";
	str indents = "  ";
	
	set[loc] compilationUnits = toSet([c |c <-codeLineModel]);
	
	map[loc, list[CloneFragment]] clonesForCompilationUnit = clonesMappedOnCompilationUnit(compilationUnits, cloneModel);
	
	result += "<indents>\"name\":\"<projectName>\",\n";
	result += "<indents>\"update\":\"<now()>\",\n";
	result += "<indents>\"numberOfCloneClasses\":<size(cloneModel)>,\n";
	
	if (size(packageModel) > 0)
	{
		result += jsonForSubPackages(packageModel, {}, clonesForCompilationUnit, cloneModel, codeLineModel, 1);
	}
	
	result += "}";
	
	//println("createJSON:<round((systemTime() - bf) / 1000)>");
	
	return result;
}

private str jsonForSubPackages(set[Package] packages, set[CompilationUnit] compilationUnits, map[loc, list[CloneFragment]] clonesForCompilationUnit, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{
	bf = systemTime();
	
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	
	str result = "<indents>\"children\": [\n";
	
	if (size(compilationUnits) > 0)
	{
		result += jsonForCompilationUnits(compilationUnits, clonesForCompilationUnit, cloneModel, codeLineModel, indentationLevel); 
		
		if (size(packages) > 0)
		{	
			result += ",\n";
		}
		else
		{
			result += "\n";
		}
	}
	
	int counter = 0;
	
	for (p <- packages)
	{	
		counter += 1;
	
		result += "<indents>{\n";
	
		
		if (size(p.subPackages) > 0 || size(p.compilationUnits) > 0)
		{
			result += "<indents>  \"name\":\"<p.name>\",\n";
		
			result += jsonForSubPackages(p.subPackages, p.compilationUnits, clonesForCompilationUnit, cloneModel, codeLineModel, (indentationLevel + 1));
		}
		
		if (counter == size(packages))
		{
			result += "<indents>}\n";
		}
		else
		{
			result += "<indents>},\n";
		}
	}
	
	result += "<indents>]\n";
	
	//println("jsonForSubPackages:<round((systemTime() - bf) / 1000)>");
	
	return result;
}

private str jsonForCompilationUnits(set[CompilationUnit] compilationUnits, map[loc, list[CloneFragment]] clonesForCompilationUnit, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{
	bf = systemTime();

	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	str result = "";
	int counter = 0;
	
	for (c <- compilationUnits)
	{
		counter += 1;
		
		result += "<indents>{\n";
		result += "<indents>  \"name\": \"<c.name>\",\n";
		result += "<indents>  \"children\": [\n";
		result += jsonForCodeClones(c, clonesForCompilationUnit[c.file], cloneModel, codeLineModel, indentationLevel + 2);
		result += "<indents>  ]\n";
		result += "<indents>}";
		
		if (counter == size(compilationUnits))
		{
			result += "";
		}
		else
		{
			result += ",\n";
		}
	}
	
	//println("jsonForCompilationUnits:<round((systemTime() - bf) / 1000)>");
	
	return result;
}

public str jsonForCodeClones(CompilationUnit compilationUnit, list[CloneFragment] cloneFragments, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{
	bf = systemTime();
	
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);

	str result = "";
	int counter = 0;
	
	int clonedLines = 0;
	
	for (c <- cloneFragments)
	{
		counter += 1;
		clonedLines += size(c.lines);
		result += "<indents>{\n";
		
		result += "<indents>  \"name\": \"\",\n";
		result += "<indents>  \"size\":<size(c.lines)>,\n";
		result += "<indents>  \"cloneclass\": \"<c.cloneClassIdentifier>\",\n";
		result += "<indents>  \"codeFragment\": \"<htmlForCloneClass(c, cloneModel[c.cloneClassIdentifier])>\"\n";
		result += "<indents>},\n";

	}
	
	int restLines = max(size(codeLineModel[compilationUnit.file]) - clonedLines, 0);
	
	result += "<indents>{\n";
	result += "<indents>  \"name\": \"no clone\",\n";
	result += "<indents>  \"size\":<restLines>,\n";
	result += "<indents>  \"cloneclass\": \"-1\"\n";
	result += "<indents>}\n";
	
	return result;
}




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
	
	result += "<indents>\"name\":\"<projectName>\",\n<indents>\"update\":\"<now()>\",\n<indents>\"numberOfCloneClasses\":<size(cloneModel)>,\n";
	
	if (size(packageModel) > 0)
	{
		result += jsonForSubPackages(packageModel, {}, clonesForCompilationUnit, cloneModel, codeLineModel, 1);
	}
	
	result += "}";
	
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
			result += "<indents>  \"name\":\"<p.name>\",\n<jsonForSubPackages(p.subPackages, p.compilationUnits, clonesForCompilationUnit, cloneModel, codeLineModel, (indentationLevel + 1))>";
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
		
		result += "<indents>{\n<indents>  \"name\": \"<c.name>\",\n<indents>  \"children\": [\n<jsonForCodeClones(c, clonesForCompilationUnit[c.file], cloneModel, codeLineModel, indentationLevel + 2)><indents>  ]\n<indents>}";
		
		if (counter == size(compilationUnits))
		{
			result += "";
		}
		else
		{
			result += ",\n";
		}
	}
	
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
		
		result += "<indents>{\n<indents>  \"name\": \"\",\n<indents>  \"size\":<size(c.lines)>,\n<indents>  \"cloneclass\": \"<c.cloneClassIdentifier>\",\n<indents>  \"codeFragment\": \"<htmlForCloneClass(c, cloneModel[c.cloneClassIdentifier])>\"\n<indents>},\n";
	}
	
	int restLines = max(size(codeLineModel[compilationUnit.file]) - clonedLines, 0);
	
	result += "<indents>{\n<indents>  \"name\": \"no clone\",\n<indents>  \"size\":<restLines>,\n<indents>  \"cloneclass\": \"-1\"\n<indents>}\n";
	
	return result;
}




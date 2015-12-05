module visualisation::JSON

import Prelude;

import DateTime;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;
import visualisation::HTML;
import util::Math;
import visualisation::Util;

public str createJSON(str projectName, PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel)
{	
	str result = "\n{\n";
	str indents = "  ";
	
	set[loc] compilationUnits = toSet([c |c <-codeLineModel]);
	
	map[loc, list[CloneFragment]] clonesForCompilationUnit = clonesMappedOnCompilationUnit(compilationUnits, cloneModel);
	
	result += "<indents>\"name\":\"<projectName>\",\n<indents>\"update\":\"<now()>\",\n<indents>\"numberOfCloneClasses\":<size(cloneModel)>,\n";

	if (size(packageModel) > 0)
	{
		jsonForSubPackages(1, packageModel, {}, clonesForCompilationUnit, cloneModel, codeLineModel, 1);
	
		result += "tempFile1";
	}
	
	result += "}";
	
	writeToTempFile(0, result);
	
	str tempFile0 = readTempFile(0);
	
	if (size(packageModel) > 0)
	{
		tempFile0 = aggrateTempFiles(1, tempFile0, packageModel);
	}
	
	return tempFile0;
}

private void jsonForSubPackages(int counter, set[Package] packages, set[CompilationUnit] compilationUnits, map[loc, list[CloneFragment]] clonesForCompilationUnit, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{			
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	
	str result = "<indents>\"children\": [\n";

	writeToTempFile(counter, result);
	
	if (size(compilationUnits) > 0)
	{	
		jsonForCompilationUnits(counter, compilationUnits, clonesForCompilationUnit, cloneModel, codeLineModel, indentationLevel); 
		
		if (size(packages) > 0)
		{	
			result = ",\n";
		}
		else
		{
			result = "\n";
		}
		
		appendToTempFile(counter, result);
	}
	
	int packageCounter = 0;
	int innerCounter = counter;
	for (p <- packages)
	{	
		packageCounter += 1;
		
		innerCounter += 1;
		
		result = "<indents>{\n";

		if (size(p.subPackages) > 0 || size(p.compilationUnits) > 0)
		{
			jsonForSubPackages(innerCounter, p.subPackages, p.compilationUnits, clonesForCompilationUnit, cloneModel, codeLineModel, (indentationLevel + 1));
			
			result += "<indents>  \"name\":\"<p.name>\",\ntempFile<innerCounter>";
		}
		
		if (packageCounter == size(packages))
		{
			result += "<indents>}\n";
		}
		else
		{
			result += "<indents>},\n";
		}
		
		appendToTempFile(counter, result);
		

	}
	
	result = "<indents>]\n";
	
	appendToTempFile(counter, result);
}


private void jsonForCompilationUnits(int counter, set[CompilationUnit] compilationUnits, map[loc, list[CloneFragment]] clonesForCompilationUnit, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	
	int i = 0;
	
	for (c <- compilationUnits)
	{
		str result = "";
		
		i += 1;
		
		result += "<indents>{\n<indents>  \"name\": \"<c.name>\",\n<indents>  \"children\": [\n<jsonForCodeClones(c, clonesForCompilationUnit[c.file], cloneModel, codeLineModel, indentationLevel + 2)><indents>  ]\n<indents>}";
		
		if (i == size(compilationUnits))
		{
			result += "";
		}
		else
		{
			result += ",\n";
		}
		
		appendToTempFile(counter, result);
	}
}

public str jsonForCodeClones(CompilationUnit compilationUnit, list[CloneFragment] cloneFragments, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{
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

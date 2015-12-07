module visualisation::JSON

import Prelude;

import DateTime;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;
import visualisation::HTML;
import util::Math;
import visualisation::Util;

public void createJSON(str projectName, CloneType cloneType, PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel)
{	
	str result = "\n{\n";
	str indents = "  ";
	
	set[loc] compilationUnits = toSet([c |c <-codeLineModel]);
	
	map[loc, list[Clone]] clonesForCompilationUnit = clonesMappedOnCompilationUnit(compilationUnits, cloneModel);
	
	result += "<indents>\"name\":\"<projectName>\",\n<indents>\"update\":\"<now()>\",\n<indents>\"numberOfCloneClasses\":<size(cloneModel)>,\n";
	
	writeToJSONFile(projectName, result, cloneType);

	if (size(packageModel) > 0)
	{
		jsonForSubPackages(projectName, cloneType, packageModel, {}, clonesForCompilationUnit, cloneModel, codeLineModel, 1);
	}
	
	result = "}";	
	appendToJSONFile(projectName, result, cloneType);

}

private void jsonForSubPackages(str projectName, CloneType cloneType, set[Package] packages, set[CompilationUnit] compilationUnits, map[loc, list[Clone]] clonesForCompilationUnit, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{			
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	
	str result = "<indents>\"children\": [\n";

	appendToJSONFile(projectName, result, cloneType);
	
	if (size(compilationUnits) > 0)
	{	
		jsonForCompilationUnits(projectName, cloneType, compilationUnits, clonesForCompilationUnit, cloneModel, codeLineModel, indentationLevel); 
		
		if (size(packages) > 0)
		{	
			result = ",\n";
		}
		else
		{
			result = "\n";
		}
		
		appendToJSONFile(projectName, result, cloneType);
	}
	
	int packageCounter = 0;
	
	for (p <- packages)
	{	
		packageCounter += 1;
		
		result = "<indents>{\n";
		appendToJSONFile(projectName, result, cloneType);
		
		if (size(p.subPackages) > 0 || size(p.compilationUnits) > 0)
		{
			result = "<indents>  \"name\":\"<p.name>\",\n";
			appendToJSONFile(projectName, result, cloneType);
			
			jsonForSubPackages(projectName, cloneType, p.subPackages, p.compilationUnits, clonesForCompilationUnit, cloneModel, codeLineModel, (indentationLevel + 1));
		}
		
		if (packageCounter == size(packages))
		{
			result = "<indents>}\n";
		}
		else
		{
			result = "<indents>},\n";
		}
		
		appendToJSONFile(projectName, result, cloneType);
	}
	
	result = "<indents>]\n";
	appendToJSONFile(projectName, result, cloneType);
}


private void jsonForCompilationUnits(str projectName, CloneType cloneType, set[CompilationUnit] compilationUnits, map[loc, list[Clone]] clonesForCompilationUnit, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
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
		
		appendToJSONFile(projectName, result, cloneType);
	}
}

public str jsonForCodeClones(CompilationUnit compilationUnit, list[Clone] cloneFragments, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
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

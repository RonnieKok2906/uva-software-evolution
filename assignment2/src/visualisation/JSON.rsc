module visualisation::JSON

import Prelude;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;
import visualisation::HTML;

public str createJSON(PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel)
{
	str result = "\n{\n";
	str indents = "  ";
	
	result += "<indents>\"name\":\"projectName\",\n";
	
	if (size(packageModel) > 0)
	{
		result += jsonForSubPackages(packageModel, {}, cloneModel, codeLineModel, 1);
	}
	
	result += "}";
	
	return result;
}

public str jsonForCodeClones(CompilationUnit compilationUnit, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	
	list[CodeFragment] clonesForCompilationUnit = getClonesInCompilationUnit(compilationUnit.file, cloneModel);
	
	str result = "";
	int counter = 0;
	
	int clonedLines = 0;
	
	for (c <- clonesForCompilationUnit)
	{
		counter += 1;
		clonedLines += size(c[1]);
		result += "<indents>{\n";
		
		result += "<indents>  \"name\": \"\",\n";
		result += "<indents>  \"size\":<size(c[1])>,\n";
		result += "<indents>  \"cloneclass\": \"<c[0]>\",\n";
		result += "<indents>  \"codeFragment\": \"<htmlForCloneClass(c, cloneClassForCodeFragment(cloneModel, c))>\"\n";
		result += "<indents>},\n";

	}
	
	int restLines = size(codeLineModel[compilationUnit.file.top]) - clonedLines;
	result += "<indents>{\n";
	result += "<indents>  \"name\": \"no clone\",\n";
	result += "<indents>  \"size\":<restLines>,\n";
	result += "<indents>  \"cloneclass\": \"-1\"\n";
	result += "<indents>}\n";
	
	return result;
}

private str jsonForCompilationUnits(set[CompilationUnit] compilationUnits, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	str result = "";
	int counter = 0;
	
	for (c <- compilationUnits)
	{
		counter += 1;
		
		result += "<indents>{\n";
		result += "<indents>  \"name\": \"<c.name>\",\n";
		result += "<indents>  \"children\": [\n";
		result += jsonForCodeClones(c, cloneModel, codeLineModel, indentationLevel + 2);
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
	
	return result;
}

private str jsonForSubPackages(set[Package] packages, set[CompilationUnit] compilationUnits, CloneModel cloneModel, CodeLineModel codeLineModel, int indentationLevel)
{
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	
	str result = "<indents>\"children\": [\n";
	
	if (size(compilationUnits) > 0)
	{
		result += jsonForCompilationUnits(compilationUnits, cloneModel, codeLineModel, indentationLevel); 
		
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
		
			result += jsonForSubPackages(p.subPackages, p.compilationUnits, cloneModel, codeLineModel, (indentationLevel + 1));
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
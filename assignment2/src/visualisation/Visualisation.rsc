module visualisation::Visualisation

import Prelude;

import util::Math;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;

public str createJSON(PackageModel packageModel, CodeLineModel codeLineModel, list[CloneClass] cloneClasses) 
{
	str result = "\n{\n";
	str indents = "  ";
	
	result += "<indents>\"name\":\"projectName\",\n";
	
	if (size(packageModel) > 0)
	{
		result += jsonForSubPackages(packageModel, {}, cloneClasses, 1);
	}
	
	result += "}";
	
	writeFile(|project://CloneVisualisation/flare.json|, result);

	return result;
}

public str jsonForCompilationUnits(set[CompilationUnit] compilationUnits, int indentationLevel)
{
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	str result = "";
	int counter = 0;
	
	for (c <- compilationUnits)
	{
		counter += 1;
		
		result += "<indents>{\"name\": \"<c.name>\", \"size\": <size(c.lines)>, \"cloneclass\": \"<arbInt(100)>\"}";
		
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

public str jsonForSubPackages(set[Package] packages, set[CompilationUnit] compilationUnits, list[CloneClass] cloneClasses, int indentationLevel)
{
	str indents = ("" | it + "  " | i <- [0..indentationLevel]);
	
	str result = "<indents>\"children\": [\n";
	
	if (size(compilationUnits) > 0)
	{
		result += jsonForCompilationUnits(compilationUnits, indentationLevel); 
		
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
		
			result += jsonForSubPackages(p.subPackages, p.compilationUnits, cloneClasses, (indentationLevel + 1));
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
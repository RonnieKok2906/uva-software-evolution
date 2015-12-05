module visualisation::Util

import Prelude;

import model::PackageModel;
import model::CloneModel;

public void appendToJSONFile(str projectName, str string, CloneType cloneType)
{
	loc file = jsonFileForProject(projectName, cloneType);

	appendToFile(file, string);
}

public void writeToJSONFile(str projectName, str string, CloneType cloneType)
{
	loc projectFolder = projectFolder(projectName);
	
	if (!exists(projectFolder))
	{
		mkDirectory(projectFolder);
	}
	
	loc file = jsonFileForProject(projectName, cloneType);
	
	if (!exists(file))
	{	
		resolveLocation(file);
	}

	writeFile(file, string);
}

public str readJsonFile(str projectName, CloneType cloneType) = readFile(tempFileForProject(projectName), cloneType);

private loc projectFolder(str projectName) = |project://cloneVisualisation/projects| + projectName;

private loc jsonFileForProject(str projectName, CloneType cloneType)
{
	loc projectFolder = projectFolder(projectName);
	loc file;
	
	switch(cloneType)
	{
		case type1(): file = projectFolder + "type1.json";
		case type2(): file = projectFolder + "type2.json";
		case type3(): file = projectFolder + "type3.json";
		case type4(): file = projectFolder + "type4.json";
	}
	
	return file;
}
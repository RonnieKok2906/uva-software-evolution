module visualisation::Visualisation

import Prelude;

import util::Math;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;

import visualisation::JSON;
import visualisation::Util;

data CloneType = type1() | type2() | type3() | type4();

public void createVisualisation(str projectName, PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel, CloneType cloneType) 
{	
	println("Building JSON string...");
	createJSON(projectName, packageModel, codeLineModel, cloneModel);
	str JSONString = readTempFile(0);
	
	println("Writing to file..");
	loc file;
	
	loc projectFolder = |project://cloneVisualisation/projects| + projectName;
	
	if (!exists(projectFolder))
	{
		mkDirectory(projectFolder);
	}
	
	switch(cloneType)
	{
		case type1(): file = projectFolder + "type1.json";
		case type2(): file = projectFolder + "type2.json";
		case type3(): file = projectFolder + "type3.json";
		case type4(): file = projectFolder + "type4.json";
	}
	
	if (!exists(file))
	{	
		resolveLocation(file);
	}


	writeFile(file, JSONString);
}

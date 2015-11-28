module visualisation::Visualisation

import Prelude;

import util::Math;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;

import lang::json::IO;

import visualisation::HTML;
import visualisation::JSON;

data CloneType = type1() | type2() | type3() | type4();

public void createVisualisation(str projectName, PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel, CloneType cloneType) 
{
	str JSONString = createJSON(projectName, packageModel, codeLineModel, cloneModel);
	
	loc file;
	
	loc projectFolder = |project://cloneVisualisation| + projectName;
	
	if (!exists(projectFolder))
	{
		println("wants to create again");
	
		mkDirectory(projectFolder);
	}
	
	switch(cloneType)
	{
		case type1(): file = projectFolder + "type1.json";
		case type2(): file = projectFolder + "type2.json";
		case type3(): file = projectFolder + "type3.json";
		case type4(): file = projectFolder + "type4.json";
	}
	
	println("file:<file>");
	
	if (!exists(file))
	{
		println("wants to create file again: <file>" );
	
		resolveLocation(file);
	}

	writeFile(file, JSONString);
}

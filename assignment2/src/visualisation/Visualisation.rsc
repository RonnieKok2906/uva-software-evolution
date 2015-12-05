module visualisation::Visualisation

import Prelude;

import util::Math;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;

import visualisation::JSON;
import visualisation::Util;

public void createVisualisation(str projectName, PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel, CloneType cloneType) 
{	
	println("Building JSON file...");
	createJSON(projectName, cloneType, packageModel, codeLineModel, cloneModel);
}

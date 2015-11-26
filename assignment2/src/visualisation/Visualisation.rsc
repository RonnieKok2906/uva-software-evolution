module visualisation::Visualisation

import Prelude;

import util::Math;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;

import lang::json::IO;

import visualisation::HTML;
import visualisation::JSON;


public void createVisualisation(PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel) 
{
	str JSONString = createJSON(packageModel, codeLineModel, cloneModel);
	
	writeFile(|project://CloneVisualisation/flare.json|, JSONString);
}

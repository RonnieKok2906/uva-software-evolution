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

public void createVisualisation(PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel, CloneType cloneType) 
{
	str JSONString = createJSON(packageModel, codeLineModel, cloneModel);
	
	loc file;
	
	switch(cloneType)
	{
		case type1(): file = |project://CloneVisualisation/type1.json|;
		case type2(): file = |project://CloneVisualisation/type2.json|;
		case type3(): file = |project://CloneVisualisation/type3.json|;
		case type4(): file = |project://CloneVisualisation/type4.json|;
	}
	
	writeFile(file, JSONString);
}

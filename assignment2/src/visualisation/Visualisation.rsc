module visualisation::Visualisation

import Prelude;

import util::Math;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;

import visualisation::JSON;
import visualisation::Util;

import type1::Config;
import type2::Config;
import type3::Config;

public void createVisualisation(str projectName, PackageModel packageModel, CodeLineModel codeLineModel, CloneModel cloneModel, CloneType cloneType, Config config) 
{	
	createJSON(projectName, cloneType, packageModel, codeLineModel, cloneModel, config);
}

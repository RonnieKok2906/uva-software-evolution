module Main

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::PackageModel;
import model::CodeLineModel;
import model::CloneModel;

import type1::Type1;

import visualisation::Visualisation;

public list[loc] projects()
{
	return [|project://smallsql0.21_src|, |project://hsqldb-2.3.1|, |project://testCloneSource|];
}

public void detectClones(loc project)
{
	println("Building M3 model for project...");
	M3 m3Model = createM3FromEclipseProject(project);

	//println("Building AST model for project...");
	//set[Declaration] declarations = createAstsFromEclipseProject(project, false);
	
	println("Building PackageModel...");
	PackageModel packageModel = createPackageModel(m3Model);
	
	println("Building CodeLineModel...");
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	
	CloneModel cloneModelType1 = type1::Type1::detectClones(codeLineModel);
	
	str JSONType1 = createJSON(packageModel, codeLineModel, cloneModelType1);
	
	println("jsonType1:" + JSONType1);
}
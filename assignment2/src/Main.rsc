module Main

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::PackageModel;
import model::PackageModelTests;
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

//Test Functions
public void runAllTests()
{
	list[tuple[str,list[bool]]] tests = [
								<"CodeLineModel.rsc Tests", model::CodeLineModel::allTests()>,
								<"PackageModelTests.rsc Tests", model::PackageModelTests::allTests()>
								];

	int numberOfFailedTests = 0;
	int numberOfPassedTests = 0;
	
	println("-----------------------------------------------------------");
	
	for (<name, subTests> <- tests)
	{
		tuple[int passed, int failed] result = runTests(subTests);
		numberOfPassedTests += result.passed;
		numberOfFailedTests += result.failed;
		println("<name> : <result.passed> passed, <result.failed> failed");
	}
	
	println("-----------------------------------------------------------");
	println("TEST REPORT:<numberOfPassedTests> passed, <numberOfFailedTests> failed");
	println("-----------------------------------------------------------");
}

//Function to run a list of tests
public tuple[int passed, int failed] runTests(list[bool] tests)
{
	int numberOfTests = size(tests);
	int passedTests = size([t | t <- tests, t == true]);
	return <passedTests, numberOfTests - passedTests>;
}
module Main

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::PackageModel;
import model::PackageModelTests;
import model::CodeLineModel;
import model::CloneModel;

import typeUtil::TypeUtilTests;

import type1::Type1;
import type1::Type1Tests;
import type2::Type2;
import type2::Type2Tests;
import type3::Type3;
import type3::Type3Tests;

import normalization::Normalization;
import normalization::Config;

import type1::Config;
import type2::Config;
import type3::Config;

import visualisation::HTMLTests;
import visualisation::Visualisation;


public list[loc] projects()
{
	return [|project://smallsql0.21_src|, |project://hsqldb-2.3.1|, |project://testCloneSource|];
}

public void detectClones(loc project)
{
	println("Building M3 model for project...");
	M3 m3Model = createM3FromEclipseProject(project);

	println("Building CodeLineModel...");
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	
	println("Building PackageModel...");
	PackageModel packageModel = createPackageModel(m3Model, codeLineModel);

	int numberOfMinumumLines = 30;

	//Type 1
	Config config1 = type1::Config::defaultConfiguration;
	config1.minimumNumberOfLines = numberOfMinumumLines;
	
	println("Building cloneModelType1...");
	CloneModel cloneModelType1 = type1::Type1::clonesInProject(codeLineModel, config1);

	println("Building visualisation Type1..");
	createVisualisation(project.authority, packageModel, codeLineModel, cloneModelType1, type1(), config1);
	
	//Prepare Type2 and Type3
	println("Preparing for Type2 and Type3...");
	
	println("Building AST model for project...");
	set[Declaration] declarations = createAstsFromEclipseProject(project, false);
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	normalizationConfig.filterSmallerThanBlocks = false;
	
	println("Extracting normalized subtrees..");
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees(declarations, normalizationConfig);
	
	println("Extracting normalized subblocks..");
	map[int, list[list[CodeLine]]] subblocks = ();
	
	if (normalizationConfig.filterSmallerThanBlocks)
	{
		 subblocks = findSubblocks(declarations, normalizationConfig, codeLineModel);
	}
	
	//Type 2
	println("Building cloneModelType2...");
	Config config2 = type2::Config::defaultConfiguration;
	config2.minimumNumberOfLines = numberOfMinumumLines;
	CloneModel cloneModelType2 = type2::Type2::clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config2);

	println("Building visualisation Type2..");
	createVisualisation(project.authority, packageModel, codeLineModel, cloneModelType2, type2(), config2);
	
	////Type 3
	println("Building cloneModelType3..");
	Config config3 = type3::Config::defaultConfiguration;
	config3.minimumNumberOfLines = numberOfMinumumLines;
	CloneModel cloneModelType3 = type3::Type3::clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config3);
	
	println("Building visualisation Type3..");
	createVisualisation(project.authority, packageModel, codeLineModel, cloneModelType3, type3(), config3);
}

//Test Functions
public void runAllTests()
{
	list[tuple[str,list[bool]]] tests = [
								<"CodeLineModel.rsc Tests", model::CodeLineModel::allTests()>,
								<"PackageModelTests.rsc Tests", model::PackageModelTests::allTests()>,
								<"HTMLTests.rsc Tests", visualisation::HTMLTests::allTests()>,
								<"TypeUtilTests.rcs Tests", typeUtil::TypeUtilTests::allTests()>,
								<"Type1Tests.rsc Tests", type1::Type1Tests::allTests()>,
								<"Type2Tests.rsc Tests", type2::Type2Tests::allTests()>,
								<"Type3Tests.rsc Tests", type3::Type3Tests::allTests()>
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
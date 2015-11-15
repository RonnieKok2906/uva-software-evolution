module Main

import Prelude;

import util::Benchmark;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Conversion;
import Util;

import model::MetricTypes;
import model::CodeLineModel;
import model::CodeUnitModel;
import model::ClassModel;

import volume::Volume;
import volume::VolumeTests;

import complexity::Complexity;
import complexity::Conversion;
import complexity::CyclomaticComplexity;

import unitSize::UnitSize;
import unitSize::UnitSizeTests;

import duplication::Duplication;
import duplication::DuplicationTests;

import unitTesting::Ranking;

import wmc::WMC;
import wmc::WMCTests;


public list[loc] projects()
{
	return [|project://smallsql0.21_src|, |project://hsqldb-2.3.1|, |project://testSource|, |project://hsqldb|];
}

public void rankMaintainability(loc project)
{	
	println("Building M3 model for project...");
	M3 m3Model = createM3FromEclipseProject(project);

	println("Building Ast model for project...");
	set[Declaration] declarations = createAstsFromEclipseProject(project, false);
	
	println("Building CodeLineModel...");
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	println("Building CodeUnitModel...");
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, declarations);
	
	//Volume
	LOC volumeResults = projectVolume(codeLineModel);
	Rank volumeRanking = convertLOCToRankForJava(volumeResults);
	printVolume(volumeResults, volumeRanking);
	SourceCodeProperty volumeProperty = volume(volumeRanking);
	
	//Complexity
	ComplexityMetric complexityPie = projectComplexity(codeUnitModel);
	Rank complexityRanking = convertPieToRank(complexityPie);
	printComplexity(complexityPie);
	SourceCodeProperty complexityPerUnitProperty = complexityPerUnit(complexityRanking);
	
	//Duplication
	DuplicationMetric duplicationResult = projectDuplication(codeLineModel);
	Rank duplicationRanking = convertPercentageToRank(duplicationResult);
	printDuplication(duplicationResult);
	SourceCodeProperty duplicationProperty = duplication(duplicationRanking);
	
	//UnitSize
	UnitSizeMetric unitSizeResults = projectUnitSize(codeUnitModel); 
	Rank unitSizeRanking = convertUnitSizeMetricToRank(unitSizeResults);
	printUnitSize(unitSizeResults, unitSizeRanking);
	SourceCodeProperty unitSizeProperty = unitSize(unitSizeRanking);
	
	//UnitTesting
	Rank unitTestingRanking = projectUnitTesting(codeLineModel);
	printUnitTesting(unitTestingRanking);
	SourceCodeProperty unitTestingProperty = unitTesting(unitTestingRanking);
	
	//Maintainability
	printMaintainability(<volumeProperty, unitSizeProperty, complexityPerUnitProperty, duplicationProperty, unitTestingProperty>);
	
	
	//WMC
	ClassModel classModel = createClassModel(m3Model, codeUnitModel);
	WMC wmc = projectWMC(classModel);
	printTopWMC(wmc);	
}

//Test Functions
public void runAllTests()
{
	list[tuple[str,list[bool]]] tests = [
								<"CodeLineModel.rsc Tests", model::CodeLineModel::allTests()>,
								<"Conversion.rsc Tests", Conversion::allTests()>,
								<"volume::VolumeTests.rsc Tests", volume::VolumeTests::allTests()>,
								<"complexity::Complexity.rsc Tests", complexity::Complexity::allTests()>,
								<"complexity::Conversion.rsc Tests", complexity::Conversion::allTests()>,
								<"complexity::CyclomaticComplexity.rcs Tests", complexity::CyclomaticComplexity::allTests()>,
								<"duplication::Ranking.rsc Tests", duplication::DuplicationTests::allTests()>,
								<"unitSize::UnitSize.rsc Tests", unitSize::UnitSize::allTests()>,
								<"wmc::WMCTests.rsc Tests", wmc::WMCTests::allTests()>
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
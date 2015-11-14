module Main

import Prelude;

import util::Benchmark;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Conversion;

import model::MetricTypes;
import model::CodeLineModel;
import model::CodeUnitModel;

import volume::Volume;
import volume::VolumeTests;

import complexity::Ranking;
import complexity::Conversion;
import complexity::CyclomaticComplexity;

import unitSize::UnitSize;

import duplication::Ranking;

import unitTesting::Ranking;


public list[loc] projects()
{
	return [|project://smallsql0.21_src|, |project://hsqldb-2.3.1|, |project://testSource|, |project://hsqldb|];
}

public void rankMaintainability(loc project)
{
	before = systemTime();
	
	println("Building M3 model for project...");
	M3 m3Model = createM3FromEclipseProject(project);

	println("Building Ast model for project...");
	set[Declaration] declarations = createAstsFromEclipseProject(project, false);
	
	println("Building CodeLineModel...");
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	println("Building CodeUnitModel...");
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, declarations);
	
	//Volume
	println("Ranking Volume for project...");
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
	Rank unitTestingRank = projectUnitTesting(codeLineModel);
	SourceCodeProperty unitTestingProperty = unitTesting(unitTestingRank);
	
	println("time consumed:<(systemTime() - before) * 0.0000001> seconds\n");
	
	Conversion::printResults((
								analysability() : averageRankOfPropertyRankings([volumeProperty, duplicationProperty, unitSizeProperty, unitTestingProperty]),
								changeability() : averageRankOfPropertyRankings([complexityPerUnitProperty, duplicationProperty]),
								stability() : averageRankOfPropertyRankings([unitTestingProperty]),
								testability() : averageRankOfPropertyRankings([complexityPerUnitProperty, unitSizeProperty, unitTestingProperty])
							));
	
}

//Test functions
public void runAllTests()
{
	list[tuple[str,list[bool]]] tests = [
								<"CodeLineModel.rsc Tests", model::CodeLineModel::allTests()>,
								<"Conversion.rsc Tests", Conversion::allTests()>,
								<"volume::VolumeTests.rsc Tests", volume::VolumeTests::allTests()>,
								<"complexity::Ranking.rsc Tests", complexity::Ranking::allTests()>,
								<"complexity::Conversion.rsc Tests", complexity::Conversion::allTests()>,
								<"complexity::CyclomaticComplexity.rcs Tests", complexity::CyclomaticComplexity::allTests()>,
								<"duplication::Ranking.rsc Tests", duplication::Ranking::allTests()>
								];

	for (<name, subTests> <- tests)
	{
		tuple[int passed, int failed] result = runTests(subTests);
		println("<name> : <result.passed> passed, <result.failed> failed");
	}
}

private tuple[int passed, int failed] runTests(list[bool] tests)
{
	int numberOfTests = size(tests);
	int passedTests = size([t | t <- tests, t == true]);
	return <passedTests, numberOfTests - passedTests>;
}
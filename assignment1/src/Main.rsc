module Main

import MetricTypes;
import Conversion;
import volume::Volume;
import volume::VolumeConversion;
import complexity::Complexity;
import complexity::ComplexityConversion;
import duplication::Duplication;
import unitTesting::UnitTesting;
import unitSize::UnitSize;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;

public list[loc] projects()
{
	return [|project://smallsql0.21_src|, |project://hsqldb-2.3.1|];
}

public map[MaintainabilityMetric, Rank] rankMaintainability(loc project)
{
	set[Declaration] declarations = createAstsFromEclipseProject(project, true);

	Rank volumeRank = projectVolume(declarations);
	SourceCodeProperty volumeProperty = volume(volumeRank);
	
	Rank complexityPerUnitRank = projectComplexity(declarations);
	SourceCodeProperty complexityPerUnitProperty = complexityPerUnit(complexityPerUnitRank);
	
	Rank duplicationRank = projectDuplication(declarations);
	SourceCodeProperty duplicationProperty = duplication(duplicationRank);
	
	Rank unitSizeRank = projectUnitSize(declarations); 
	SourceCodeProperty unitSizeProperty = unitSize(unitSizeRank);
	
	Rank unitTestingRank = projectUnitTesting(declarations);
	SourceCodeProperty unitTestingProperty = unitTesting(unitTestingRank);
	
	return (
			analysability() : averageRankOfPropertyRankings([volumeProperty, duplicationProperty, unitSizeProperty, unitTestingProperty]),
			changeability() : averageRankOfPropertyRankings([complexityPerUnitProperty, duplicationProperty]),
			stability() : averageRankOfPropertyRankings([unitTestingProperty]),
			testability() : averageRankOfPropertyRankings([complexityPerUnitProperty, unitSizeProperty, unitTestingProperty])
			);
}

//Test functions
public void runAllTests()
{
	list[tuple[str,list[bool]]] tests = [
								<"volumeConversionTests", volume::VolumeConversion::allTests()>,
								<"complexityTests", complexity::Complexity::allTests()>,
								<"complexityConversionTests", complexity::ComplexityConversion::allTests()>
								];

	str passed = "passed";
	str failed = "failed";

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
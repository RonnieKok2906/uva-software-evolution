module Main

import MetricTypes;
import Conversion;
import volume::Volume;
import volume::VolumeConversion;
import complexity::Ranking;
import complexity::Conversion;
import complexity::CyclomaticComplexity;
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
	return [|project://smallsql0.21_src|, |project://hsqldb-2.3.1|, |project://testSource|];
}

public map[MaintainabilityMetric, Rank] rankMaintainability(loc project)
{
	set[Declaration] declarations = createAstsFromEclipseProject(project, true);

	//Volume
	Rank volumeRank = projectVolume(declarations);
	SourceCodeProperty volumeProperty = volume(volumeRank);
	println(volumeProperty);
	
	//Complexity
	Rank complexityPerUnitRank = projectComplexity(declarations);
	SourceCodeProperty complexityPerUnitProperty = complexityPerUnit(complexityPerUnitRank);
	println(complexityPerUnitProperty);
	println(complexityPie(declarations));
	
	//Duplication
	Rank duplicationRank = projectDuplication(declarations);
	SourceCodeProperty duplicationProperty = duplication(duplicationRank);
	println(duplicationProperty);
	
	//UnitSize
	Rank unitSizeRank = projectUnitSize(declarations); 
	SourceCodeProperty unitSizeProperty = unitSize(unitSizeRank);
	println(unitSizeProperty);
	
	//UnitTesting
	Rank unitTestingRank = projectUnitTesting(declarations);
	SourceCodeProperty unitTestingProperty = unitTesting(unitTestingRank);
	println(unitTestingProperty);
	
	println("\n");
	
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
								<"Conversion.rsc Tests", Conversion::allTests()>,
								<"volume::Conversion.rsc Tests", volume::VolumeConversion::allTests()>,
								<"complexity::Ranking.rsc Tests", complexity::Ranking::allTests()>,
								<"complexity::Conversion.rsc Tests", complexity::Conversion::allTests()>,
								<"complexity::CyclomaticComplexity.rcs Tests", complexity::CyclomaticComplexity::allTests()>
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
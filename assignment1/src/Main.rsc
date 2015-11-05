module Main

import MetricTypes;
import Conversion;
import volume::Volume;
import complexity::Complexity;
import duplication::Duplication;
import unitTesting::UnitTesting;
import unitSize::UnitSize;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

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


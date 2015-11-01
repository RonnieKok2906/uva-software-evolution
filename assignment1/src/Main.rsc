module Main

import MetricTypes;
import Conversion;
import volume::Volume;
import complexity::Complexity;
import duplication::Duplication;
import unitTesting::UnitTesting;
import unitSize::UnitSize;

public list[loc] projects()
{
	return [|project://smallsql0.21_src|, |project://hsqldb-2.3.1|];
}

public map[MaintainabilityMetric, Rank] rankMaintainability(loc project)
{
	Rank volumeRank = projectVolume(project);
	SourceCodeProperty volumeProperty = volume(volumeRank);
	
	Rank complexityPerUnitRank = projectComplexity(project);
	SourceCodeProperty complexityPerUnitProperty = complexityPerUnit(complexityPerUnitRank);
	
	Rank duplicationRank = projectDuplication(project);
	SourceCodeProperty duplicationProperty = duplication(duplicationRank);
	
	Rank unitSizeRank = projectUnitSize(project); 
	SourceCodeProperty unitSizeProperty = unitSize(unitSizeRank);
	
	Rank unitTestingRank = projectUnitTesting(project);
	SourceCodeProperty unitTestingProperty = unitTesting(unitTestingRank);
	
	return (
			analysability() : averageRankOfPropertyRankings([volumeProperty, duplicationProperty, unitSizeProperty, unitTestingProperty]),
			changeability() : averageRankOfPropertyRankings([complexityPerUnitProperty, duplicationProperty]),
			stability() : averageRankOfPropertyRankings([unitTestingProperty]),
			testability() : averageRankOfPropertyRankings([complexityPerUnitProperty, unitSizeProperty, unitTestingProperty])
			);
}


module volume::Volume

import lang::java::jdt::m3::AST;

import MetricTypes;
import volume::VolumeConversion;

public Rank projectVolume(set[Declaration] declarations)
{
	LOC pLoc = projectLinesOfCode(declarations);

	return convertLOCToRankForJava(pLoc);
}

//TODO: implement
private LOC projectLinesOfCode(set[Declaration] declarations)
{
	return 0;
}
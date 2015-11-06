module volume::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import MetricTypes;
import volume::VolumeConversion;

public Rank projectVolume(set[Declaration] declarations)
{
	LOC pLoc = projectLinesOfCode(declarations);

	return convertLOCToRankForJava(pLoc);
}

public list[loc files] filesFromModel(M3 model) = [name | <name, _> <- model@declarations];

public map[loc file, list[Comment] comments] commentsPerFile(M3 model)
{
	map[loc file, list[Comment] comments] mapToReturn = ();
	
	for (file <- filesFromModel(model))
	{
		mapToReturn[file] = [comment(c) |  <_,c> <- model@documentation, locationInFile(c, file)];
	}

	return mapToReturn;
}

public bool locationInFile(loc location, loc file) = location.path == file.path;

//TODO: implement
private LOC projectLinesOfCode(set[Declaration] declarations)
{
	return 0;
}

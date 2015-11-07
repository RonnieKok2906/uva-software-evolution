module volume::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import MetricTypes;
import volume::VolumeConversion;

//
// Returns the Volume metric ranking for a given project.
//
public Rank projectVolume(set[Declaration] declarations)
{
	list[loc] sourcefiles = getFilesFromASTs(declarations);

	LOC pLoc = linesOfCodeInProject(sourcefiles);

	return convertLOCToRankForJava(pLoc);
}

//
// Returns the locations of all source files from a given AST list.
//
public set[loc files] getFilesFromASTs(set[Declaration] declarations)
{	
	set[loc] files = [];

	for (d <- declarations)
	{
		visit(d)
		{
			case compilationUnit(Declaration package, _, _): files += package@src;
		}
	}
	return files;
}

//
// Returns the locations of all source files from a given M3 model.
// (Theoretically this should give the same result as getFilesFromASTs()). 
//
public list[loc files] getFilesFromModel(M3 model) = 
	[file.top | <name, file> <- model@declarations, name.scheme == "java+compilationUnit"];



public LOC linesOfCodeInProject(list[loc] sourcefiles)
{
	LOC linesOfCode = 0;
	for(file <- sourcefiles) 
	{
		linesOfCode += linesOfCodeInFile(file);
	}
	return linesOfCode;
}

public LOC linesOfCodeInFile(loc sourcefile)
{
	return 0;
} 



public map[loc file, list[Comment] comments] commentsPerFile(M3 model)
{
	map[loc file, list[Comment] comments] mapToReturn = ();
	
	for (file <- filesFromModel(model))
	{
		mapToReturn[file] = [comment(c) |  <_,c> <- model@documentation, locationInFile(c, file)];
	}

	return mapToReturn;
}


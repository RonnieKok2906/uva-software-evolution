module volume::Volume

import IO;
import List;
import String;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::MetricTypes;
import model::CodeLineModel;
import volume::VolumeConversion;

//
// Returns the Volume metric ranking for a given project.
//
public tuple[LOC,Rank] projectVolume(CodeLineModel model)
{
	LOC pLoc = (0 | it + size(model[file]) | file <- model);

	return <pLoc, convertLOCToRankForJava(pLoc)>;
}

// All below is now deprecated! :)

//
// Returns the Volume metric ranking for a given project.
//
public tuple[LOC,Rank] projectVolume(M3 model)
{
	LOC pLoc = linesOfCodeInProject(model);

	return <pLoc, convertLOCToRankForJava(pLoc)>;
}

public LOC linesOfCodeInProject(M3 model)
{
	list[loc] sourcefiles = getFilesFromModel(model);
	LOC totalLinesOfCode = 0;
	
	for(file <- sourcefiles) 
	{
		//print("<file> : ");
		int linesOfCode = linesOfCodeInFile(model, file);
		//println("<linesOfCode>");
		totalLinesOfCode += linesOfCode;
	}
	return totalLinesOfCode;
}

public LOC linesOfCodeInFile(M3 model, loc sourcefile)
{
	str sourcecode = readFile(sourcefile);
	list[tuple[int,int]] commentOffset = getCommentOffsetsOfFile(model, sourcefile);
	
	sourcecode = removeComments(sourcecode, commentOffset);
	
	return size([ line | line <- split("\n", sourcecode), !isEmpty(trim(line)) ]);
}

//
// Returns the locations of all source files from a given M3 model.
// (Theoretically this should give the same result as getFilesFromASTs()). 
//
public list[loc files] getFilesFromModel(M3 model) = 
	[file.top | <name, file> <- model@declarations, name.scheme == "java+compilationUnit"];

//
// Returns the offset locations of all the comments in a given source file.
//	
public list[tuple[int,int]] getCommentOffsetsOfFile(M3 model, loc sourcefile) =
	[ <location.offset, location.length> | <_,location> <- model@documentation, location.top == sourcefile ];

//
// Removes all the comments from a given source code string.
//	
public str removeComments(str sourcecode, list[tuple[int,int]] comments) 
{
	// Make sure the offsets are sorted in descending order.
	comments = reverse(sort(comments));

	for(offset <- comments) 
	{
		sourcecode = remove(sourcecode, offset[0], offset[1]);
	}
	return sourcecode;
}

//
// Removes a part of a string.
//
public str remove(str subject, int startPos, int length)
{
	str removed = "";
	if(startPos > 0) 
	{
		removed = substring(subject, 0, startPos);
	}
	if(startPos < size(subject)) 
	{
		removed += substring(subject, startPos + length);
	}
	return removed;
}


//
// Returns the locations of all source files from a given AST list.
//
public list[loc files] getFilesFromASTs(set[Declaration] declarations)
{	
	list[loc] files = [];

	for (d <- declarations)
	{
		visit(d)
		{
			case compilationUnit(Declaration package, _, _): files += package@src.top;
		}
	}
	return files;
}
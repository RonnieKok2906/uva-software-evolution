module CodeModel

import IO;
import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import MetricTypes;

alias CodeModel = map[loc fileName, set[CodeLine] lines];

public CodeModel createCodeModel(M3 model)
{
	map[loc, list[Comment]] comments = commentsPerFile(model);

	return (f : relevantCodeLinesFromFile(f, comments[f]) | f <- getFilesFromModel(model));
}

public list[loc files] getFilesFromModel(M3 model) = 
	[file.top | <name, file> <- model@declarations, name.scheme == "java+compilationUnit"];

private map[loc, list[Comment]] commentsPerFile(M3 model)
{
	map[loc file, list[Comment] comments] mapToReturn = ();
	
	for (file <- getFilesFromModel(model))
	{
		mapToReturn[file] = [comment(c) |  <_,c> <- model@documentation, locationInFile(c, file)];
	}
	
	return mapToReturn;
}

private bool locationInFile(loc location, loc file) = location.path == file.path;

private set[CodeLine] relevantCodeLinesFromFile(loc fileName, list[Comment] comments)
{
	list[CodeLine] linesWithoutComments = removeCommentsFromFile(fileName, comments);
	
	return toSet([codeLine(fileName, i, trim(linesWithoutComments[i].codeFragment)) | i <- [0..size(linesWithoutComments)], !isEmptyLine(linesWithoutComments[i])]);
}

private list[CodeLine] removeCommentsFromFile(loc fileName, list[Comment] comments)
{ 
	list[CodeFragment] lines = readFileLines(fileName);

	list[CodeLine] linesToReturn = [];
	
	for (i <- [0..size(lines)])
	{
		linesToReturn += codeLine(fileName, i, lines[i]);
	}
	
	for (c <- comments)
	{
		list[CodeFragment] commentLines = readFileLines(c.location);
		
		for (i <- [0..size(commentLines)])
		{
			int lineNumber = c.location.begin.line + i - 1;		
			CodeFragment fragmentWithComment = lines[lineNumber];

			str resultLine = ("" | it + s | s <- split(commentLines[i], fragmentWithComment));
	
			linesToReturn[lineNumber] = codeLine(fileName, i, resultLine);
		}
	}

	return linesToReturn;
} 

private bool isEmptyLine(CodeLine line) = isEmptyLine(line.codeFragment);

private bool isEmptyLine(str line)
{ 
	return /^\s*$/ := line;
}
module type2::CodeLineModel2

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import visualisation::HTML;

alias LOC = int;
data Comment = comment(loc location);
data CodeLine2 = codeLine(loc fileName, int lineNumber, str codeFragment, bool onlyComment);

alias CodeLineModel2 = map[loc compilationUnit, map[int lineNumber, CodeLine2 line] lines];

//Public functions

public CodeLineModel2 createCodeLineModel(M3 model)
{
	map[loc, list[Comment]] comments = commentsPerFile(model);

	return (f : relevantCodeFromFile(f, comments[f]) | f <- getFilesFromModel(model));
}


//Private functions

private list[loc files] getFilesFromModel(M3 model) = 
	[file.top | <name, file> <- model@declarations, name.scheme == "java+compilationUnit"];

private map[loc, list[Comment]] commentsPerFile(M3 model)
{
	map[loc file, list[Comment] comments] mapToReturn = ();
	
	for (file <- getFilesFromModel(model))
	{
		mapToReturn[file] = [comment(c) |  <_,c> <- model@documentation, c.path == file.path];
	}
	
	return mapToReturn;
}

private map[int, CodeLine2] relevantCodeFromFile(loc fileName, list[Comment] comments)
{
	list[CodeLine2] linesWithoutComments = removeCommentsFromFile(fileName, comments);
	
	return (i+1:codeLine(fileName.top, i+1, cleanString(linesWithoutComments[i].codeFragment), isEmptyLine(linesWithoutComments[i])) | i <- [0..size(linesWithoutComments)]);
}

private list[CodeLine2] removeCommentsFromFile(loc fileName, list[Comment] comments)
{ 
	list[str] lines = readFileLines(fileName);

	list[CodeLine2] linesToReturn = [];
	
	for (i <- [0..size(lines)])
	{
		linesToReturn += codeLine(fileName.top, i+1, lines[i], false);
	}
	
	for (c <- comments)
	{
		list[str] commentLines = readFileLines(c.location);
		
		for (i <- [0..size(commentLines)])
		{
			int lineNumber = c.location.begin.line + i;		
			str fragmentWithComment = lines[lineNumber - 1];

			str resultLine = ("" | it + s | s <- split(commentLines[i], fragmentWithComment));
	
			linesToReturn[lineNumber - 1] = codeLine(fileName, lineNumber, resultLine, false);
		}
	}

	return linesToReturn;
} 

private bool isEmptyLine(CodeLine2 line) = isEmptyLine(line.codeFragment);

private bool isEmptyLine(str line)
{ 
	return /^\s*$/ := line;
}

//Tests
public list[bool] allTests() = [
								tabsAreEmpty(),
								whiteSpacesAreEmpty(),
								newLinesAreEmpty(),
								characterIsNotEmpty(),
								strangeCharacterIsNotEmpty(),
								noCharacterIsEmpty()
								]; 

test bool tabsAreEmpty() = isEmptyLine("\t\t\t");
test bool whiteSpacesAreEmpty() = isEmptyLine("  ");
test bool newLinesAreEmpty() = isEmptyLine("\n\r");
test bool characterIsNotEmpty() = !isEmptyLine("a");
test bool strangeCharacterIsNotEmpty() = !isEmptyLine("@");
test bool noCharacterIsEmpty() = isEmptyLine("");
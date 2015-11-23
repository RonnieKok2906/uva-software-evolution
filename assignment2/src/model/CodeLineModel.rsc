module model::CodeLineModel

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

alias LOC = int;
data Comment = comment(loc location);
data CodeLine = codeLine(loc fileName, int lineNumber, str codeFragment);

alias CodeLineModel = map[loc compilationUnit, list[CodeLine] lines];

//Public functions

public CodeLineModel createCodeLineModel(M3 model)
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

private list[CodeLine] relevantCodeFromFile(loc fileName, list[Comment] comments)
{
	list[CodeLine] linesWithoutComments = removeCommentsFromFile(fileName, comments);
	
	return [codeLine(fileName, i+1, trim(linesWithoutComments[i].codeFragment)) | i <- [0..size(linesWithoutComments)], !isEmptyLine(linesWithoutComments[i])];
}

private list[CodeLine] removeCommentsFromFile(loc fileName, list[Comment] comments)
{ 
	list[str] lines = readFileLines(fileName);

	list[CodeLine] linesToReturn = [];
	
	for (i <- [0..size(lines)])
	{
		linesToReturn += codeLine(fileName, i+1, lines[i]);
	}
	
	for (c <- comments)
	{
		list[str] commentLines = readFileLines(c.location);
		
		for (i <- [0..size(commentLines)])
		{
			int lineNumber = c.location.begin.line + i;		
			str fragmentWithComment = lines[lineNumber - 1];

			str resultLine = ("" | it + s | s <- split(commentLines[i], fragmentWithComment));
	
			linesToReturn[lineNumber - 1] = codeLine(fileName, lineNumber, resultLine);
		}
	}

	return linesToReturn;
} 

private bool isEmptyLine(CodeLine line) = isEmptyLine(line.codeFragment);

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
module model::CodeLineModel

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
alias LOC = int;
data Comment = comment(loc location);
data CodeLine = codeLine(loc fileName, int lineNumber, str codeFragment, bool hasCode);

alias CodeLineModel = map[loc compilationUnit, map[int lineNumber, CodeLine line] lines];

//Public functions

public CodeLineModel createCodeLineModel(M3 model)
{
	map[loc, list[Comment]] comments = commentsPerFile(model);

	return (f : relevantCodeFromFile(f, comments[f]) | f <- getFilesFromModel(model));
}

public list[CodeLine] sortedLinesForCompilationUnit(loc compilationUnit, CodeLineModel codeLineModel)
{
	map[int, CodeLine] lines = codeLineModel[compilationUnit];

	return sort(toList(range(lines)), bool(CodeLine l1, CodeLine l2){ return l1.lineNumber < l2.lineNumber; });
}

public CodeLineModel removeEmptyLines(CodeLineModel codeLineModel)
{
	for (f <- codeLineModel)
	{
		map[int, CodeLine] lines = codeLineModel[f];
		map[int, CodeLine] linesToReturn = ();
		
		for (lineNumber <- lines)
		{
			if (lines[lineNumber].hasCode)
			{
				linesToReturn[lineNumber] = lines[lineNumber];
			}
		}
		
		codeLineModel[f] = linesToReturn;
	}
	
	return codeLineModel;
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

private map[int, CodeLine] relevantCodeFromFile(loc fileName, list[Comment] comments)
{
	list[CodeLine] linesWithoutComments = removeCommentsFromFile(fileName, comments);
	
	return (i+1:codeLine(fileName.top, i+1, linesWithoutComments[i].codeFragment, !isEmptyLine(linesWithoutComments[i])) | i <- [0..size(linesWithoutComments)]);
}

private list[CodeLine] removeCommentsFromFile(loc fileName, list[Comment] comments)
{ 
	list[str] lines = readFileLines(fileName);

	list[CodeLine] linesToReturn = [];
	
	for (i <- [0..size(lines)])
	{
		linesToReturn += codeLine(fileName.top, i+1, lines[i], true);
	}
	
	for (c <- comments)
	{
		list[str] commentLines = readFileLines(c.location);
		
		for (i <- [0..size(commentLines)])
		{
			int lineNumber = c.location.begin.line + i;		
			str fragmentWithComment = lines[lineNumber - 1];

			str resultLine = ("" | it + s | s <- split(commentLines[i], fragmentWithComment));
	
			linesToReturn[lineNumber - 1] = codeLine(fileName, lineNumber, resultLine, true);
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
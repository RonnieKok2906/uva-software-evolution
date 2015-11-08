module duplication::Ranking

import List;
import Set;
import String;
import ListRelation;
import IO;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import MetricTypes;

import volume::Volume;


public Rank projectDuplication(set[Declaration] declarations, M3 model)
{
	real numberOfDuplicatedLines = toReal(size(duplicationsInProject(declarations, model)));
	real numberOfTotalLines = toReal(linesOfCodeInProject(model));
	real percentage = 100 * numberOfDuplicatedLines / numberOfTotalLines;
	println("dLOC:<numberOfDuplicatedLines>, LOC:<numberOfTotalLines>, percentage:<percentage>");
	
	if (percentage > 20) return minusMinus();
	if (percentage > 10) return minus();
	if (percentage > 5) return neutral();
	if (percentage > 3) return plus();
	
	return plusPlus();
}

public set[CodeLine] duplicationsInProject(set[Declaration] declarations, M3 model)
{	
	map[list[CodeFragment], set[CodeBlock]] mapping = indexAllCodeFragments(declarations, model);
	
	map[list[CodeFragment], set[CodeBlock]] duplicationsMap = (cf : mapping[cf] | list[CodeFragment] cf <- mapping,  size(mapping[cf]) > 1);
	
	//for (d <- duplicationsMap)
	//{
	//	//println("The codeFragment is duplicated in <size(duplicationsMap[d])> files:");
	//	
	//	for (cf <- d)
	//	{
	//	//	println(cf);
	//	}
	//	
	//	//println("+++++");
	//}
	
	set[CodeLine] duplicatedLines = {};
	
	for (dm <- duplicationsMap)
	{
		set[CodeBlock] setOfCodeBlocks = duplicationsMap[dm];
		
		for (codeBlock <- setOfCodeBlocks)
		{
			for (codeLine <- codeBlock)
			{
				duplicatedLines += codeLine;
			}
		}
	}
	
	return duplicatedLines;
}

public map[list[CodeFragment], set[CodeBlock]] indexAllCodeFragments(set[Declaration] declarations, M3 model)
{
	map[loc, list[Comment]] commentsInProject = commentsPerFile(model);
	
	list[loc] files = getFilesFromModel(model);
	
	lrel[list[CodeFragment], CodeBlock] blocks = ([] | it + allDuplicateCandidatesOfNLinesFromFile(f, 6, commentsInProject[f]) | f <- files);

	return ListRelation::index(blocks);
}

public list[CodeLine] relevantCodeLinesFromFile(loc fileName, list[Comment] comments)
{
	list[CodeFragment] stringLines = readFileLines(fileName);
	
	list[CodeLine] linesWithoutComments = removeCommentsFromCode(fileName, stringLines, comments);
	
	return [codeLine(fileName, i, stringLines[i]) | i <- [0..size(linesWithoutComments)], !isEmptyLine(linesWithoutComments[i])];
}

public list[CodeLine] removeCommentsFromCode(loc fileName, list[CodeFragment] lines, list[Comment] comments)
{ 
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

public lrel[list[CodeFragment], CodeBlock] allDuplicateCandidatesOfNLinesFromFile(loc fileName, int nrOfLinesInBlock, list[Comment] comments)
{
	list[CodeLine] codeLines = relevantCodeLinesFromFile(fileName, comments);
	
	if (size(codeLines) < nrOfLinesInBlock) return [];
	
	lrel[list[CodeFragment], list[CodeLine]] blocks = [];
	
	for (i <- [0..size(codeLines)-nrOfLinesInBlock + 1])
	{
		list[CodeLine] linesInBlock = [l | l <- codeLines[i..i+nrOfLinesInBlock]];
		
		list[CodeFragment] cfs = [l.codeFragment | l <- linesInBlock];
		
		blocks += [<cfs, linesInBlock>];
	}
	
	return blocks;
}

public map[loc file, list[Comment] comments] commentsPerFile(M3 model)
{
	map[loc file, list[Comment] comments] mapToReturn = ();
	
	for (file <- getFilesFromModel(model))
	{
		mapToReturn[file] = [comment(c) |  <_,c> <- model@documentation, locationInFile(c, file)];
	}
	
	return mapToReturn;
}
 
public bool locationInFile(loc location, loc file) = location.path == file.path;

public bool isEmptyLine(CodeLine line) = isEmptyLine(line.codeFragment);

public bool isEmptyLine(str line)
{ 
	return /^\s*$/ := line;
}

test bool tabsAreEmpty() = isEmptyLine("\t\t\t");
test bool whiteSpacesAreEmpty() = isEmptyLine("  ");
test bool newLinesAreEmpty() = isEmptyLine("\n\r");
test bool characterIsNotEmpty() = !isEmptyLine("a");
test bool strangeCharacterIsNotEmpty() = !isEmptyLine("@");
test bool noCharacterIsEmpty() = isEmptyLine("");
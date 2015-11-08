module duplication::Ranking

import List;
import Set;
import String;
import ListRelation;
import IO;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import MetricTypes;

import volume::Volume;


//TODO: implement
public Rank projectDuplication(set[Declaration] declarations)
{
	return neutral();
}

//TODO: implement
public map[list[CodeFragment], set[CodeBlock]] duplicationsInProject(set[Declaration] declarations)
{
	set[loc] files = toSet(getFilesFromASTs(declarations));
	
	mapping = indexAllCodeFragments(declarations);
	
	duplications = (cf : mapping[cf] | list[CodeFragment] cf <- mapping,  size(mapping[cf]) > 2);
	
	for (d <- duplications)
	{
		println("The codeFragment is duplicated in <size(duplications[d])> files:");
		
		for (cf <- d)
		{
			println(cf);
		}
		
		println("+++++");
	}
	
	return duplications;
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

public list[CodeLine] relevantCodeLinesFromFile(loc fileName, list[Comment] comments)
{
	list[CodeFragment] stringLines = readFileLines(fileName);
	
	list[CodeLine] linesWithoutComments = removeCommentsFromCode(fileName, stringLines, comments);
	
	return [codeLine(fileName, i, stringLines[i]) | i <- [0..size(linesWithoutComments)], !isEmptyLine(linesWithoutComments[i])];
}


public CodeLine codeLineWithoutComment(list[Comment] comments, CodeLine line)
{
	for (c <- comments)
	{
		int currentLineNumber = line.lineNumber;
	
		if (currentLineNumber >= c.location.begin.line && currentLineNumber <= c.location.end.line)
		{		
			list[CodeFragment] commentStringLines = readFileLines(c.location);
			
			CodeFragment commentOnCurrentLine = commentStringLines[currentLineNumber - c.location.begin.line];
			
			CodeFragment currentLineWithoutComment = ("" | it + s | s <- split(commentOnCurrentLine, line.codeFragment));
		
			return codeLine(line.fileName, currentLineNumber, currentLineWithoutComment);
		}
	}

	return line;
}

 
public lrel[list[CodeFragment], CodeBlock] allDuplicateCandidatesOfNLinesFromFile(loc fileName, int nrOfLinesInBlock, list[Comment] comments)
{
	list[CodeLine] codeLines = relevantCodeLinesFromFile(fileName, comments);
	
	if (size(codeLines) < nrOfLinesInBlock) return [];
	
	lrel[list[CodeFragment], list[CodeLine]] blocks = [];
	
	for (i <- [0..size(codeLines)-nrOfLinesInBlock])
	{
		list[CodeLine] linesInBlock = [l | l <- codeLines[i..i+nrOfLinesInBlock]];
		
		list[CodeFragment] cfs = [l.codeFragment | l <- linesInBlock];
		
		blocks += [<cfs, linesInBlock>];
	}
	
	return blocks;
}

public map[list[CodeFragment], set[CodeBlock]] indexAllCodeFragments(set[Declaration] declarations)
{
	//This is temporarily hard coded;
	M3 model = createM3FromEclipseProject(|project://smallsql0.21_src|);

	map[loc, list[Comment]] commentsInProject = commentsPerFile(model);
	
	list[loc] files = getFilesFromASTs(declarations);
	
	lrel[list[CodeFragment], CodeBlock] blocks = ([] | it + allDuplicateCandidatesOfNLinesFromFile(f, 6, commentsInProject[f]) | f <- files);

	

	return ListRelation::index(blocks);
}


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
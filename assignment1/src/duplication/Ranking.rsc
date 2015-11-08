module duplication::Ranking

import List;
import Set;
import String;
import ListRelation;
import IO;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Main;

import MetricTypes;

import volume::Volume;


//TODO: implement
public Rank projectDuplication(set[Declaration] declarations)
{
	return neutral();
}

//TODO: implement
public map[list[CodeFragment], set[loc]] duplicationsInProject(set[Declaration] declarations)
{
	set[loc] files = toSet(getFilesFromASTs(declarations));
	
	mapping = indexAllCodeFragments(declarations);
	
	return (cf : mapping[cf] | list[CodeFragment] cf <- mapping,  size(mapping[cf]) > 1);
}


public list[CodeLine] relevantCodeLinesFromFile(loc fileName)
{
	M3 model = createM3FromEclipseProject(projects()[0]);

	map[loc, list[Comment]] commentsInProject = commentsPerFile(model);
	
	list[Comment] commentsInFile = commentsInProject[fileName];

	list[CodeFragment] stringLines = readFileLines(fileName);
	
	list[CodeLine] relevantLines = [];
	
	for (i <- [0..size(stringLines)])
	{
		CodeFragment lineCodeFragment = stringLines[i];
		
		CodeLine lineWithoutComment = codeLineWithoutComment(commentsInFile, codeLine(fileName, i, lineCodeFragment));
		
		if (!isEmptyLine(lineWithoutComment.codeFragment))
		{
			relevantLines += lineWithoutComment;
		}
	}
	
	return relevantLines;
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

 
public lrel[list[CodeFragment], CodeBlock] allDuplicateCandidatesOfNLinesFromFile(loc fileName, int nrOfLinesInBlock)
{
	list[CodeLine] codeLines = relevantCodeLinesFromFile(fileName);
	
	lrel[list[CodeFragment], list[CodeLine]] blocks = [];
	
	for (i <- [0..size(codeLines)])
	{
		list[CodeLine] linesInBlock = [l | l <- codeLines[i..i+6]];
		
		list[CodeFragment] cfs = [l.codeFragment | l <- linesInBlock];
		
		blocks += [<cfs, linesInBlock>];
	}
	
	return blocks;
}

public map[list[CodeFragment], set[CodeBlock]] indexAllCodeFragments(set[Declaration] declarations)
{
	list[loc] files = getFilesFromASTs(declarations);
	
	lrel[list[CodeFragment], CodeBlock] blocks = ([] | it + allDuplicateCandidatesOfNLinesFromFile(b, 6) | b <- files);

	return ListRelation::index(blocks);
}

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
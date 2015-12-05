module type2::Util

import Prelude;

import lang::java::jdt::m3::AST;

import type2::CodeLineModel2;
import model::CodeLineModel;

public bool isDeclaration(node n)
{	
	if (Declaration d := n)
	{	
		return true;
	}
	
	return  false;
}

public bool isStatement(node n)
{
	if (Statement s := n)
	{
		return true;
	}
	
	return false;
}

public bool isExpression(node n)
{
	if(Expression e := n)
	{
		return true;	
	}
	
	return false;
}

public bool hasAnnotatedSource(node n)
{
	map[str, value] annotations = getAnnotations(n);
						
	if ("src" in annotations)
	{
		return true;
	}
	
	return false;
}

public loc getSourceFromNode(node n)
{	
	if (hasAnnotatedSource(n))
	{
		if (Declaration d := n)
		{
			return d@src;
		}
	
		if (Statement s := n)
		{
			return s@src;
		}
	
		if (Expression e := n)
		{
			return e@src;
		}
	}
}

public bool isCloneSubtreeCandidate(node n)
{
	if (isDeclaration(n) || isStatement(n))
	{					
		if (hasAnnotatedSource(n))
		{	
			return true;
		}
	}
	
	return false;
}

//Could be replaced to the CodeLineModel
public list[CodeLine] codeLinesForFragement(loc codeFragment, CodeLineModel2 codeLineModel)
{
	int begin = codeFragment.begin[0];
	int end = codeFragment.end[0];
	
	map[int, CodeLine2] linesOfFile = codeLineModel[codeFragment.top];
	
	returnList = [];
	
	int numberOfLines = size(linesOfFile);
	
	for (i <- [begin..end+1])
	{
		CodeLine2 l = linesOfFile[i];
	
		if (!l.onlyComment)
		{
			returnList += model::CodeLineModel::codeLine(l.fileName, l.lineNumber, 0, l.codeFragment);
		}
	}
	
	return returnList;
}

private bool consistsOfMoreThanNLines(int numberOfLines, loc codeFragment, CodeLineModel2 codeLineModel)
{
	return size(codeLinesForFragement(codeFragment, codeLineModel)) >= numberOfLines;
}

public bool oneOfTheCodeFragmentsHasEnoughLines(int numberOfLines, set[loc] codeFragments, CodeLineModel2 codeLineModel)
{
	for (c <- codeFragments)
	{
		if (consistsOfMoreThanNLines(numberOfLines, c, codeLineModel))
		{
			return true;
		}
	}
	
	return false;
}
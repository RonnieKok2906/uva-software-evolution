module typeUtil::TypeUtil

import Prelude;

import lang::java::jdt::m3::AST;

import model::CodeLineModel;

public map[node, set[loc]] filterAllPossibleSubtreeCandidatesOfNLinesOrMore(int numberOflines, map[node, set[loc]] subtrees, CodeLineModel codeLineModel)
{	
	map[node, set[loc]] clonedSubtrees = (k:subtrees[k] | k <- subtrees, size(subtrees[k]) > 1);
			
	map[node, set[loc]] subtreesToReturn = ();
	
	for (k <- clonedSubtrees)
	{
		if (anyOfTheCodeFragmentsHasEnoughLines(numberOflines, clonedSubtrees[k], codeLineModel))
		{
			subtreesToReturn[k] = clonedSubtrees[k];
		}
	}
	
	return subtreesToReturn;
}

public set[node] subtreesFromNode(node n)
{
	set[node] subtrees = {};

	visit(n)
	{
		case node i: 
		{
			if (isCloneSubtreeCandidate(n))
			{
				subtrees += i;
			}
		}
	}
	
	return subtrees;
}

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
public list[CodeLine] codeLinesForFragement(loc codeFragment, CodeLineModel codeLineModel)
{
	int begin = codeFragment.begin[0];
	int end = codeFragment.end[0];
	
	map[int, CodeLine] linesOfFile = codeLineModel[codeFragment.top];
	
	returnList = [];
	
	int numberOfLines = size(linesOfFile);
	
	for (i <- [begin..end+1])
	{
		CodeLine l = linesOfFile[i];
	
		returnList += model::CodeLineModel::codeLine(l.fileName, l.lineNumber, l.codeFragment, l.hasCode);
	}
	
	return returnList;
}

public list[CodeLine] onlyLinesWithCode(list[CodeLine] lines)
{
	return [line | line <- lines, line.hasCode];
}

private bool consistsOfMoreThanNLines(int numberOfLines, loc codeFragment, CodeLineModel codeLineModel)
{
	int nr = size(codeLinesForFragement(codeFragment, codeLineModel)) ;
		
	return nr >= numberOfLines;
}

public bool anyOfTheCodeFragmentsHasEnoughLines(int numberOfLines, set[loc] codeFragments, CodeLineModel codeLineModel)
{
	return any(c <- codeFragments, consistsOfMoreThanNLines(numberOfLines, c, codeLineModel));
}

public map[node, set[loc]] addNodeToSubtrees(node n, map[node, set[loc]] subtrees)
{
	if (n in subtrees)
	{
		subtrees[n] += getSourceFromNode(n);
	}
	else
	{
		subtrees[n] = {getSourceFromNode(n)};
	}
	
	return subtrees;
}

public list[list[&T]] allPossibleSublistsWithAMinimumNumberOfItems(list[&T] items, int minimumNumberOfItems)
{
	if (size(items) == minimumNumberOfItems)
	{
		return [items];
	}
	else
	{
		set[list[&T]] returnList = {};
		
		for (i <- [0..size(items)])
		{
			list[&T] tempList = delete(items, i);
			
			returnList += {tempList};
			
			returnList += toSet(allPossibleSublistsWithAMinimumNumberOfItems(tempList, minimumNumberOfItems));
		}
		
		return toList(returnList);
	}
}

public list[list[&T]] subsequences(list[&T] items)
{
	if (size(items) == 1)
	{
		return [items];
	}
	else
	{
		set[list[&T]] returnList = {[]};
		
		for (i <- [0..size(items)])
		{
			list[&T] tempList = delete(items, i);
			
			returnList += {tempList};
			
			returnList += toSet(subsequences(tempList));
		}
		
		return toList(returnList);
	}
}

public int newIdentifier(list[int] identifiers)
{
	return (0 | max(it, i) | i <- identifiers) + 1;
}
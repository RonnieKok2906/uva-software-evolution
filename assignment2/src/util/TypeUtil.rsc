module util::TypeUtil

import Prelude;

import lang::java::jdt::m3::AST;

import util::Normalization;
import model::CodeLineModel;
import type2::Config;
import type3::Config;

public map[node, set[loc]] findAllPossibleNormalizedSubtrees(set[Declaration] declarations, Config config)
{
	map[node, set[loc]] subtrees = ();

	for (d <- declarations)
	{				
		visit(d)
		{
			case node n : {
			
							if (isCloneSubtreeCandidate(n))
							{
								subtrees = addNodeToSubtrees(normalizeNode(n, config), subtrees);
							}
						}
		}
		
	}
	
	return subtrees;
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
	
	println("thisNode:<n>:<isExpression(n)>");
}

public bool isCloneSubtreeCandidate(node n)
{
	if (isDeclaration(n) || isStatement(n) || isExpression(n))
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
	
		if (l.hasCode)
		{
			returnList += model::CodeLineModel::codeLine(l.fileName, l.lineNumber, 0, l.codeFragment, l.hasCode);
		}
	}
	
	return returnList;
}

private bool consistsOfMoreThanNLines(int numberOfLines, loc codeFragment, CodeLineModel codeLineModel)
{
	int nr = size(codeLinesForFragement(codeFragment, codeLineModel)) ;
	
	//println("consists:<nr>,<nr >= numberOfLines>");
	
	return nr >= numberOfLines;
}

public bool allTheCodeFragmentsHasEnoughLines(int numberOfLines, set[loc] codeFragments, CodeLineModel codeLineModel)
{
	//if (size(codeFragments) > 60)
	//{
	//	println("++++++++++++");	
	//}
	//else
	//{	println("---------------");
	//}

	return all(c <- codeFragments, consistsOfMoreThanNLines(numberOfLines, c, codeLineModel));
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
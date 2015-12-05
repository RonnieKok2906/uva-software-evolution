module type2::Type2

import Prelude;
import ListRelation;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;

import type2::Util;
import type2::Config;

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations)
{
	map[node, set[loc]] subtrees = findAllPossibleSubtrees(declarations);

	map[node, set[loc]] cloneCandidates = filterAllPossibleSubtreeCandidatesOfMoreThanNLines(type2::Config::numberOfLines, subtrees, codeLineModel);

	map[node, set[loc]] subsumedCandidates = subsumeCandidatesWhenPossible(cloneCandidates);

	CloneModel cloneModel = createCloneModelFromCandidates(subsumedCandidates, codeLineModel);

	return cloneModel;
}

private map[node, set[loc]] findAllPossibleSubtrees(set[Declaration] declarations)
{
	map[node, set[loc]] subtrees = ();

	for (d <- declarations)
	{				
		visit(d)
		{
			case node n : {
			
							if (isCloneSubtreeCandidate(n))
							{
								subtrees = addNodeToSubtrees(normalizeNode(n), subtrees);
							}
						}
		}
		
	}
	
	return subtrees;
}



private map[node, set[loc]] addNodeToSubtrees(node n, map[node, set[loc]] subtrees)
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

private node normalizeNode(node subtree)
{	
	return subtree;
}

private map[node, set[loc]] filterAllPossibleSubtreeCandidatesOfMoreThanNLines(int numberOflines, map[node, set[loc]] subtrees, CodeLineModel codeLineModel)
{	
	map[node, set[loc]] clonedSubtrees = (k:subtrees[k] | k <- subtrees, size(subtrees[k]) > 1);
			
	map[node, set[loc]] subtreesToReturn = ();
	
	for (k <- clonedSubtrees)
	{
		if (oneOfTheCodeFragmentsHasEnoughLines(numberOflines, clonedSubtrees[k], codeLineModel))
		{
			subtreesToReturn[k] = clonedSubtrees[k];
		}
	}
	
	return subtreesToReturn;
}

private map[node, set[loc]] subsumeCandidatesWhenPossible(map[node, set[loc]] candidates)
{
	map[node, set[loc]] returnMap = ();
	
	for (c <- candidates)
	{
		bool canBeSubsumed = (false | it || nodesCanBeSubsumed(c, r) | r <- candidates, size(candidates[c]) <= size(candidates[r]));
		
		if (!canBeSubsumed)
		{	
			returnMap[c] = candidates[c];
		}
	}
	
	return returnMap;
}

private bool nodesCanBeSubsumed(node toBeSubsumedNode, node referenceNode)
{
	set[node] toBeSubsumedNodeSubtrees = subtreesFromNode(toBeSubsumedNode);
	set[node] referenceNodeSubtrees = subtreesFromNode(referenceNode);
	
	return toBeSubsumedNodeSubtrees < referenceNodeSubtrees;
}


private set[node] subtreesFromNode(node n)
{
	set[node] subtrees = {};

	visit(n)
	{
		case node i: {
							if (isCloneSubtreeCandidate(n))
							{
								subtrees += i;
							}
		}
	}
	
	return subtrees;
}

private CloneModel createCloneModelFromCandidates(map[node, set[loc]] candidates, CodeLineModel codeLineModel)
{
	CloneModel rawCloneModel = ();
	
	int counter = 0;
	
	for (c <- candidates)
	{
		counter += 1;
		
		rawCloneModel[counter] = createCloneClass(counter, candidates[c], codeLineModel);
	}
	
	return rawCloneModel;
	
//	CloneModel subsumedCodeModel = ();
//	
//	counter = 0;
//	
//	for (c <- rawCloneModel)
//	{
//		bool canBeSubsumed = (false | it || cloneClassCanBeSubsumed(rawCloneModel[r], rawCloneModel[c]) | r <- rawCloneModel);
//		
//		if (!canBeSubsumed)
//		{
//			counter += 1;
//			
//			subsumedCodeModel[counter] = [<counter, cf.cloneIdentifier, cf.lines> | cf <- rawCloneModel[c]];
//		}
//	}
//
//	return subsumedCodeModel;
}

//private bool cloneClassCanBeSubsumed(CloneClass referencedCloneClass, CloneClass toBeSubsumed)
//{
//	if (referencedCloneClass == toBeSubsumed)
//	{
//		return false;	
//	}
//
//	if (size(referencedCloneClass) != size(toBeSubsumed))
//	{
//		return false;
//	}
//	
//	str toBeSubsumedCodeFragment = ("" | it + l.codeFragment + " " | l <- toBeSubsumed[0].lines);
//	str referenceCodeFragment = ("" | it + l.codeFragment + " " | l <- referencedCloneClass[0].lines);
//	
//	//str toBeSubsumedCodeFragment = readFile(toBeSubsumed[0].
//	//str referenceCodeFragment = ("" | it + l.codeFragment + " " | l <- referencedCloneClass[0].lines);
//	
//	return contains(toBeSubsumedCodeFragment, referenceCodeFragment);
//	
//}

private CloneClass createCloneClass(int classIdentifier, set[loc] locations, CodeLineModel codeLineModel)
{
	CloneClass cc = [];

	int counter = 1;
	
	for (l <- locations)
	{
		cc += <classIdentifier, counter, codeLinesForFragement(l, codeLineModel)>;
	}

	return cc;
}
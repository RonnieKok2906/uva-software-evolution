module type2::Type2

import Prelude;
import ListRelation;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import type2::CodeLineModel2;
import model::CloneModel;

import type2::Util;
import type2::Config;

public CloneModel clonesInProject(CodeLineModel2 codeLineModel, set[Declaration] declarations)
{
	map[node, set[loc]] subtrees = findAllPossibleSubtrees(declarations);

	map[node, set[loc]] cloneCandidates = filterAllPossibleSubtreeCandidatesOfMoreThanNLines(type2::Config::numberOfLines, subtrees, codeLineModel);

	cloneCandidates = subsumeCandidatesWhenPossible(cloneCandidates);

	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates, codeLineModel);

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

private map[node, set[loc]] filterAllPossibleSubtreeCandidatesOfMoreThanNLines(int numberOflines, map[node, set[loc]] subtrees, CodeLineModel2 codeLineModel)
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
	
	list[node] sortedNodeList = sort(domain(candidates), bool(node a, node b){ return size(subtreesFromNode(a)) < size(subtreesFromNode(b)); });
	
	for (n <- sortedNodeList)
	{
		set[loc] tempLocations = candidates[n];
		
		candidates = candidates - (n:tempLocations);
	
		bool canBeSubsumed = any(r <- domain((candidates - returnMap)), nodesCanBeSubsumed(n, r), locationsCanBeSubsumed(tempLocations, candidates[r]));
		
		if (!canBeSubsumed)
		{	
			returnMap += (n:tempLocations);
		}
	}
	
	return returnMap;
}

private bool locationsCanBeSubsumed(set[loc] toBeSubsumedLocations, set[loc] referenceLocations)
{
	return all(l <- toBeSubsumedLocations, locationCanBeSubsumed(l, referenceLocations));
}

private bool locationCanBeSubsumed(loc toBeSubsumedLocation, set[loc] referenceLocations)
{
	return any(r <- referenceLocations, locationAIsPartOfLocationB(toBeSubsumedLocation, r));
}

private bool locationAIsPartOfLocationB(loc a, loc b)
{
	int beginA = a.begin[0];
	int beginB = b.begin[0];
	int endA = a.end[0];
	int endB = b.end[0];
	
	return beginA >= beginB && beginA <= endB && endA <= endB;
}

private bool nodesCanBeSubsumed(node toBeSubsumedNode, node referenceNode)
{
	set[node] toBeSubsumedNodeSubtrees = {toBeSubsumedNode};
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

private CloneModel createCloneModelFromCandidates(map[node, set[loc]] candidates, CodeLineModel2 codeLineModel)
{
	CloneModel rawCloneModel = ();
	
	int counter = 0;
	
	for (c <- candidates)
	{
		counter += 1;
		
		rawCloneModel[counter] = createCloneClass(counter, candidates[c], codeLineModel);
	}
	
	return rawCloneModel;
}

private CloneClass createCloneClass(int classIdentifier, set[loc] locations, CodeLineModel2 codeLineModel)
{
	CloneClass cc = [];

	int counter = 1;
	
	for (l <- locations)
	{
		cc += <classIdentifier, counter, codeLinesForFragement(l, codeLineModel)>;
	}

	return cc;
}
module type2::Type2

import Prelude;
import ListRelation;
import util::Math;

import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;

import type2::Util;
import type2::Config;
import type2::Normalization;
import type2::Subsumption;

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations)
{
	return clonesInProject(codeLineModel, declarations, defaultConfiguration);
}

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations, Config config)
{
	map[node, set[loc]] subtrees = findAllPossibleNormalizedSubtrees(declarations, config);

	map[node, set[loc]] cloneCandidates = filterAllPossibleSubtreeCandidatesOfNLinesOrMore(config.numberOfLines, subtrees, codeLineModel);

	cloneCandidates = subsumeCandidatesWhenPossible(cloneCandidates);

	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates, codeLineModel);

	return cloneModel;
}

private map[node, set[loc]] findAllPossibleNormalizedSubtrees(set[Declaration] declarations, Config config)
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


private map[node, set[loc]] filterAllPossibleSubtreeCandidatesOfNLinesOrMore(int numberOflines, map[node, set[loc]] subtrees, CodeLineModel codeLineModel)
{	
	map[node, set[loc]] clonedSubtrees = (k:subtrees[k] | k <- subtrees, size(subtrees[k]) > 1);
			
	map[node, set[loc]] subtreesToReturn = ();
	
	for (k <- clonedSubtrees)
	{
		if (allTheCodeFragmentsHasEnoughLines(numberOflines, clonedSubtrees[k], codeLineModel))
		{
			subtreesToReturn[k] = clonedSubtrees[k];
		}
	}
	
	return subtreesToReturn;
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
}

private CloneClass createCloneClass(int classIdentifier, set[loc] locations, CodeLineModel codeLineModel)
{
	CloneClass cc = [];

	int counter = 1;
	
	for (l <- locations)
	{
		cc += clone(classIdentifier, counter, l.top, codeLinesForFragement(l, codeLineModel));
	}

	return cc;
}
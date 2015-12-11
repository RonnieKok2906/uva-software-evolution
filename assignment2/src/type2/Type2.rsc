module type2::Type2

import Prelude;

import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;

import type2::Config;
import util::Subsumption;

import util::TypeUtil;

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

public map[node, set[loc]] filterAllPossibleSubtreeCandidatesOfNLinesOrMore(int numberOflines, map[node, set[loc]] subtrees, CodeLineModel codeLineModel)
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

public CloneModel createCloneModelFromCandidates(map[node, set[loc]] candidates, CodeLineModel codeLineModel)
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
module typeUtil::CloneModelFactory

import Prelude;

import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;

import type2::Config;
import type2::Subsumption;

import typeUtil::TypeUtil;

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
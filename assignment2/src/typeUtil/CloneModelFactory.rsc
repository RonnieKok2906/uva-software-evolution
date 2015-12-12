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

public CloneModel createCloneModelFromCandidates(map[int, list[list[CodeLine]]] candidates)
{
	CloneModel rawCloneModel = ();
	
	int counter = 0;
	
	for (c <- candidates)
	{
		counter += 1;

		rawCloneModel[counter] = createCloneClass(counter, candidates[c]);
	}
	
	return rawCloneModel;
}

private CloneClass createCloneClass(int classIdentifier, list[list[CodeLine]] codeFragments)
{
	CloneClass cc = [];

	int counter = 1;
	
	for (cf <- codeFragments)
	{	
		cc += clone(classIdentifier, counter, cf[0].fileName, cf);
	}

	return cc;
}


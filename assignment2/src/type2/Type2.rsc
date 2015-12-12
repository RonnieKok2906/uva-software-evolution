module type2::Type2

import Prelude;

import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;

import type2::Config;

import type2::Subsumption;

import util::Normalization;
import util::TypeUtil;
import util::CloneModelFactory;


public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations)
{
	return clonesInProject(codeLineModel, declarations, defaultConfiguration);
}

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations, Config config)
{
	map[node, set[loc]] subtrees = findAllPossibleNormalizedSubtrees(declarations, config);

	return clonesInProjectFromNormalizedSubtrees(subtrees, codeLineModel);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] subtrees, CodeLineModel codeLineModel)
{
	map[node, set[loc]] cloneCandidates = filterAllPossibleSubtreeCandidatesOfNLinesOrMore(type2::Type2::defaultConfiguration.minimumNumberOfLines, subtrees, codeLineModel);

	cloneCandidates = subsumeCandidatesWhenPossible(cloneCandidates);

	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates, codeLineModel);

	return cloneModel;
}


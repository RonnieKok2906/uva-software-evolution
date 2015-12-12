module type2::Type2

import Prelude;

import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;

import type2::Config;
import type2::Subsumption;

import normalization::Normalization;
import normalization::Config;

import typeUtil::TypeUtil;
import typeUtil::CloneModelFactory;


public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations)
{
	return clonesInProject(codeLineModel, declarations, normalization::Config::defaultConfiguration);
}

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations, Config normalizationConfig, Config config)
{
	map[node, set[loc]] subtrees = findAllPossibleNormalizedSubtrees(declarations, normalizationConfig);

	return clonesInProjectFromNormalizedSubtrees(subtrees, codeLineModel, config);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] subtrees, CodeLineModel codeLineModel)
{
	return clonesInProjectFromNormalizedSubtrees(subtrees, codeLineModel, type2::Config::defaultConfiguration);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] subtrees, CodeLineModel codeLineModel, Config config)
{
	map[node, set[loc]] cloneCandidates = filterAllPossibleSubtreeCandidatesOfNLinesOrMore(config.minimumNumberOfLines, subtrees, codeLineModel);

	cloneCandidates = subsumeCandidatesWhenPossible(cloneCandidates);

	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates, codeLineModel);

	return cloneModel;
}
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
	map[node, set[loc]] subtrees = findAllRelevantNormalizedSubtrees(declarations, normalizationConfig);

	return clonesInProjectFromNormalizedSubtrees(subtrees, codeLineModel, config);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] normalizedSubtrees, CodeLineModel codeLineModel)
{
	return clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, codeLineModel, type2::Config::defaultConfiguration);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] normalizedSubtrees, CodeLineModel codeLineModel, Config config)
{
	map[node, set[loc]] duplicatedSubtrees = (k : m | k <- normalizedSubtrees, m := normalizedSubtrees[k], size(m) > 1);

	map[int, list[list[CodeLine]]] cloneCandidates = subsumeCandidates(duplicatedSubtrees, codeLineModel, config);

	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates);

	return cloneModel;
}
module type3::Type3

import Prelude;
import util::Math;

import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;

import typeUtil::TypeUtil;
import typeUtil::CloneModelFactory;

import normalization::Normalization;
import normalization::Config;


import type3::Config;
import type2::Subsumption;
//import type3::Subsumption;

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations)
{
	return clonesInProject(codeLineModel, declarations, normalization::Config::defaultConfiguration, type3::Config::defaultConfiguration);
}

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations, Config normalizationConfig, Config config)
{
	map[node, set[loc]] subtrees = findAllRelevantNormalizedSubtrees(declarations, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks(declarations, normalizationConfig, codeLineModel);

	return clonesInProjectFromNormalizedSubtrees(subtrees, subblocks, codeLineModel, config);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] normalizedSubtrees, map[int, list[list[CodeLine]]] subblocks, CodeLineModel codeLineModel)
{
	return clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, codeLineModel, subblocks, type3::Config::defaultConfiguration);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] normalizedSubtrees, map[int, list[list[CodeLine]]] subblocks, CodeLineModel codeLineModel, Config config)
{
	map[node, set[node]] cutSubtrees = (n:generateNodesWithNRemovedStatements(config, n, codeLineModel) | n <- normalizedSubtrees);
	
	normalizedSubtrees = addCutSubtreesToOtherSubtrees(cutSubtrees, normalizedSubtrees);

	normalizedSubtrees = (k : m | k <- normalizedSubtrees, m := normalizedSubtrees[k], size(m) > 1);
	
	
	map[int, list[list[CodeLine]]] cloneCandidates = subsumeCandidates(normalizedSubtrees, subblocks, codeLineModel, config);
	
	println("creating cloneModel type-3..");
	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates);
	
	
	
//	cloneCandidates = filterAllPossibleSubtreeCandidatesOfNLinesOrMore(config.minimumNumberOfLines, normalizedSubtrees, codeLineModel);
//
//	cloneCandidates = subsumeCandidatesWhenPossibleType(cloneCandidates, cutSubtrees);
//
//	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates, codeLineModel);
	
	return cloneModel;
}


private map[node, set[loc]] addCutSubtreesToOtherSubtrees(map[node, set[node]] cutSubtrees, map[node, set[loc]] normalizedSubtrees)
{
	for (k <- cutSubtrees)
	{
		for (r <- cutSubtrees[k])
		{
			if (r in normalizedSubtrees)
			{
				normalizedSubtrees[r] += normalizedSubtrees[k];
			}
			else
			{
				normalizedSubtrees[r] = normalizedSubtrees[k];
			}
		}
	}
	
	return normalizedSubtrees;
}

private set[node] generateNodesWithNRemovedStatements(Config config, node n, CodeLineModel codeLineModel)
{
	list[node] returnList = [];

	top-down visit(n)
	{	
		case b:\block(statements) : 
		{	
			returnList = generateNodesFromStatements(returnList, n, b, statements, config, codeLineModel);					
		}
		case b:\try(body, statements) :
		{	
			returnList = generateNodesFromStatements(returnList, n, b, statements, config, codeLineModel);
		}
		case b:\try(body, statements, finallyBody) :
		{
			returnList = generateNodesFromStatements(returnList, n, b, statements, config, codeLineModel);
		}
	}

	return toSet(returnList);
}

private list[node] generateNodesFromStatements(list[node] intermediateResult, node rootNode, Statement statementDeclaration, list[Statement] statements, Config config, CodeLineModel codeLineModel)
{
	list[list[Statement]] subLists = allPossibleSublistsWithAMinimumNumberOfItems(statements, max(0, size(statements) - config.numberOfLinesThatCanBeSkipped));
			
	if (size(subLists) > 1 && size(codeLinesForFragement(statementDeclaration@src, codeLineModel)) > config.minimumNumberOfLines)
	{
		for (sl <- subLists)
		{
			list[Statement] removedStatements = statements - subLists;
				
			list[int] numberOfLinesList = [size(codeLinesForFragement(r@src, codeLineModel)) | r <- removedStatements];
				
			bool removesTooMuchLines = any(r <- numberOfLinesList, r > config.numberOfLinesThatCanBeSkipped);
					
			if (!removesTooMuchLines)
			{			
				intermediateResult += generateNewBlock(rootNode, statementDeclaration, sl);
			}
		}
	}
	
	return intermediateResult;
}

private node generateNewBlock(node rootNode, Statement blockNode, list[Statement] statements)
{
	rootNode = top-down-break visit(rootNode)
	{
		case b:\block(_):
		{
			if (b == blockNode)
			{
				Statement bl = \block(statements);
		
				bl = setAnnotations(bl, getAnnotations(blockNode));
				
				insert(bl);
			}
		}
	}

	return rootNode;
}

private Statement removeStatement(Statement statement, Statement parentStatement)
{
	if (p:\block(statements) := parentStatement)
	{
		if (statement in statements)
		{
			Statement bl = \block(delete(statements, indexOf(statements, statement)));
		
			bl = setAnnotations(bl, getAnnotations(p));
			
			return bl;
		}
	}

	return statement;
}
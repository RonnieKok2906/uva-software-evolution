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
import type3::Subsumption;

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations)
{
	return clonesInProject(codeLineModel, declarations, normalization::Config::defaultConfiguration, type3::Config::defaultConfiguration);
}

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations, Config normalizationConfig, Config config)
{
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees(declarations, normalizationConfig);

	return clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, codeLineModel, config);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] normalizedSubtrees, CodeLineModel codeLineModel)
{
	return clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, codeLineModel, type3::Config::defaultConfiguration);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] normalizedSubtrees, CodeLineModel codeLineModel, Config config)
{
	println("Generating cut subtrees...<size(normalizedSubtrees)>");
	map[node, set[node]] cutSubtrees = ();//(n:generateNodesWithNRemovedStatements(config.minimumNumberOfLines, config.numberOfLinesThatCanBeSkipped, n, codeLineModel) | n <- normalizedSubtrees);
	
	//println("after generation..<size(normalizedSubtrees)>:<size(cutSubtrees)>");
	//for (k <- cutSubtrees)
	//{
	//	for (r <- cutSubtrees[k])
	//	{
	//		if (r in normalizedSubtrees)
	//		{
	//			normalizedSubtrees[r] += normalizedSubtrees[k];
	//			//subtrees[k] += subtrees[r];
	//		}
	//		else
	//		{
	//			normalizedSubtrees[r] = normalizedSubtrees[k];
	//		}
	//	}
	//}
	println("pre filter..<size(normalizedSubtrees)>");
	normalizedSubtrees = (k : m | k <- normalizedSubtrees, m := normalizedSubtrees[k], size(m) > 1);
	println("filter..<size(normalizedSubtrees)>");
	
	cloneCandidates = filterAllPossibleSubtreeCandidatesOfNLinesOrMore(config.minimumNumberOfLines, normalizedSubtrees, codeLineModel);
	
	println("subsume..<size(cloneCandidates)>");
	cloneCandidates = subsumeCandidatesWhenPossibleType(cloneCandidates, cutSubtrees);
	
	println("createCloneModel..<size(cloneCandidates)>");
	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates, codeLineModel);
	
	println("cloneModel:<size(cloneModel)>");
	
	return cloneModel;
}


private set[node] generateNodesWithNRemovedStatements(int minimumNumberOfLines, int numberOfLinesToRemove, node n, CodeLineModel codeLineModel)
{
	list[node] returnList = [];

	top-down visit(n)
	{	
		case b:\block(statements) : 
		{	
			list[list[Statement]] subLists = allPossibleSublistsWithAMinimumNumberOfItems(statements, max(0, size(statements) - numberOfLinesToRemove));
			
			println("Block number of lines:<size(codeLinesForFragement(b@src, codeLineModel))>");
			
			if (size(subLists) > 1 && size(codeLinesForFragement(b@src, codeLineModel)) > minimumNumberOfLines)
			{
				for (sl <- subLists)
				{
					list[Statement] removedStatements = statements - subLists;
				
					list[int] numberOfLinesList = [size(codeLinesForFragement(r@src, codeLineModel)) | r <- removedStatements];
				
					bool removesTooMuchLines = any(r <- numberOfLinesList, r > numberOfLinesToRemove);
					
					if (!removesTooMuchLines)
					{
						node temp = generateNewBlock(n, b, sl);
						
						//println("BLOCK:");
						
						returnList += temp;
					}
				}
			}
					
			//println("after block generation:<size(statements)>:<b@src>");							
		}
	}

	return toSet(returnList);
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
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
	map[node, set[loc]] normalizedSubtrees = findAllPossibleNormalizedSubtrees(declarations, normalizationConfig);

	return clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, codeLineModel, config);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] normalizedSubtrees, CodeLineModel codeLineModel)
{
	return clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, codeLineModel, type3::Config::defaultConfiguration);
}

public CloneModel clonesInProjectFromNormalizedSubtrees(map[node, set[loc]] normalizedSubtrees, CodeLineModel codeLineModel, Config config)
{
	map[node, set[node]] cutSubtrees = (n:generateNodesWithNRemovedStatements(config.numberOfLinesThatCanBeSkipped, n, codeLineModel) | n <- normalizedSubtrees);
	println("after generation..");
	for (k <- cutSubtrees)
	{
		for (r <- cutSubtrees[k])
		{
			if (r in normalizedSubtrees)
			{
				normalizedSubtrees[r] += normalizedSubtrees[k];
				//subtrees[k] += subtrees[r];
			}
			else
			{
				normalizedSubtrees[r] = normalizedSubtrees[k];
			}
		}
	}
	
	normalizedSubtrees = (k : m | k <- normalizedSubtrees, m := normalizedSubtrees[k], size(m) > 1);
	println("filter..");
	
	cloneCandidates = filterAllPossibleSubtreeCandidatesOfNLinesOrMore(config.minimumNumberOfLines, normalizedSubtrees, codeLineModel);
	println("subsume..");
	cloneCandidates = subsumeCandidatesWhenPossibleType3(cloneCandidates, cutSubtrees);
	println("createCloneModel..");
	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates, codeLineModel);

	return cloneModel;
}




private set[node] generateNodesWithNRemovedStatements(int numberOfLinesToRemove, node n, CodeLineModel codeLineModel)
{
	list[node] returnList = [];

	top-down visit(n)
	{	
		case b:\block(statements) : 
		{	
			list[list[Statement]] subLists = allPossibleSublistsWithAMinimumNumberOfItems(statements, max(0, size(statements) - numberOfLinesToRemove));
			
			if (size(subLists) > 1)
			{
				for (sl <- subLists)
				{
					list[Statement] removedStatements = statements - subLists;
				
					list[int] numberOfLinesList = [size(codeLinesForFragement(r@src, codeLineModel)) | r <- removedStatements];
				
					bool removesTooMuchLines = any(r <- numberOfLinesList, r > numberOfLinesToRemove);
					
					if (!removesTooMuchLines)
					{
						node temp = generateNewBlock(n, b, sl);
						
						//println("BLOCK:<b>\n\n");
						
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

public list[list[&T]] allPossibleSublistsWithAMinimumNumberOfItems(list[&T] items, int minimumNumberOfItems)
{
	if (size(items) == minimumNumberOfItems)
	{
		return [items];
	}
	else
	{
		set[list[&T]] returnList = {};
		
		for (i <- [0..size(items)])
		{
			list[&T] tempList = delete(items, i);
			
			returnList += {tempList};
			
			returnList += toSet(allPossibleSublistsWithAMinimumNumberOfItems(tempList, minimumNumberOfItems));
		}
		
		return toList(returnList);
	}
}

public list[list[&T]] subsequences(list[&T] items)
{
	if (size(items) == 1)
	{
		return [items];
	}
	else
	{
		set[list[&T]] returnList = {[]};
		
		for (i <- [0..size(items)])
		{
			list[&T] tempList = delete(items, i);
			
			returnList += {tempList};
			
			returnList += toSet(subsequences(tempList));
		}
		
		return toList(returnList);
	}
}

test bool possibleSublistsOfWithMinimumLengthTest()
{
	bool returnValue = true;

	for (i <- [3..8])
	{
		for (j <- [1..i])
		{	
			list[int] testList = [1..i+1];
			list[list[int]] sq = subsequences(testList);
			
			list[list[int]] sqTemp = [];
			
			for (list[int] g <- sq)
			{
				if (size(g) >= j)
				{
					sqTemp += [g];
				}
			}
			
			int numberOfItems = size(sqTemp);
			list[list[int]] sq2 = allPossibleSublistsWithAMinimumNumberOfItems(testList, j);
			int numberOfItems2 = size(sq2);

			returnValue = returnValue && numberOfItems == numberOfItems2;
		}	
	}
	
	return returnValue;
}

test bool subsequencesTest()
{
	bool returnValue = true;

	for (i <- [2..6])
	{
		list[list[int]] sq = subsequences([1..i+1]);
		int numberOfItems = size(sq);
		
		bool temp = size(sq) == pow(2,i) - 1;
		returnValue = returnValue && temp;
	}
	
	return returnValue;
}
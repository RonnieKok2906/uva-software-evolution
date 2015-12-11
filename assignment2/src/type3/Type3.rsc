module type3::Type3

import Prelude;
import util::Math;

import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;

import util::TypeUtil;

import type3::Config;
import type2::Type2;
import util::Subsumption;

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations)
{
	return clonesInProject(codeLineModel, declarations, defaultConfiguration);
}

public CloneModel clonesInProject(CodeLineModel codeLineModel, set[Declaration] declarations, Config config)
{
	map[node, set[loc]] subtrees = findAllPossibleNormalizedSubtrees(declarations, config);

	map[node, set[loc]] cloneCandidates = filterAllPossibleSubtreeCandidatesOfNLinesOrMore(config.numberOfLines, subtrees, codeLineModel);

	cloneCandidates = subsumeCandidatesWhenPossible(cloneCandidates);

	map[node, set[node]] cutSubtrees = (n:generateNodesWithNRemovedStatements(config.numberOfLinesThatCanBeSkipped, n) | n <- subtrees);
	println("after generation..");
	for (k <- cutSubtrees)
	{
		for (r <- cutSubtrees[k])
		{
			if (r in subtrees)
			{
				subtrees[r] += subtrees[k];
				subtrees[k] += subtrees[r];
			}
			else
			{
				subtrees[r] = subtrees[k];
			}
		}
	}
	
	subtrees = (k : m | k <-subtrees, m := subtrees[k], size(m) > 1);
	println("filter..");
	
	cloneCandidates = filterAllPossibleSubtreeCandidatesOfNLinesOrMore(config.numberOfLines, subtrees, codeLineModel);
	println("subsume..");
	cloneCandidates = subsumeCandidatesWhenPossibleType3(cloneCandidates, cutSubtrees);
	println("createCloneModel..");
	CloneModel cloneModel = createCloneModelFromCandidates(cloneCandidates, codeLineModel);

	return cloneModel;
}

public map[node, set[loc]] subsumeCandidatesWhenPossibleType3(map[node, set[loc]] candidates, map[node, set[node]] cutSubtrees)
{
	map[node, set[loc]] returnMap = ();
	println("sorting..<size(candidates)>");
	list[node] sortedNodeList = sort(domain(candidates), bool(node a, node b){ return size(subtreesFromNode(a)) < size(subtreesFromNode(b)); });
	println("sortedNodeList:<size(sortedNodeList)>");
	for (n <- sortedNodeList)
	{
		set[loc] tempLocations = candidates[n];
		
		candidates = candidates - (n:tempLocations);
		
		//tempCutSubtrees = cutSubtrees;
		//tempCut = {};
		//if (n in cutSubtress)
		//{
		//	tempCut = cutSubtrees[n];
		//}
		
		
		//cutSubtrees = cutSubtrees - (n : cutSubtrees[n]);
		bool canBeSubsumed = any(r <- domain((candidates - returnMap)), nodesCanBeSubsumed(n, r, r in cutSubtrees ? cutSubtrees[r] : {}), locationsCanBeSubsumed(tempLocations, candidates[r]));
		
		if (!canBeSubsumed)
		{	
			returnMap += (n:tempLocations);
		}
		
		println("after subsumption:<size(candidates)>");
	}
	
	return returnMap;
}

private bool nodesCanBeSubsumed(node toBeSubsumedNode, node referenceNode, set[node] cutSubtrees)
{
	if (toBeSubsumedNode in cutSubtrees)
	{
		return true;
	}

	set[node] toBeSubsumedNodeSubtrees = subtreesFromNode(toBeSubsumedNode);
	set[node] referenceNodeSubtrees = subtreesFromNode(referenceNode);
	
	return toBeSubsumedNodeSubtrees < referenceNodeSubtrees;
}

private bool locationsCanBeSubsumed(set[loc] toBeSubsumedLocations, set[loc] referenceLocations)
{
	bool returnValue = all(l <- toBeSubsumedLocations, locationCanBeSubsumed(l, referenceLocations));

	return returnValue;
}

private bool locationCanBeSubsumed(loc toBeSubsumedLocation, set[loc] referenceLocations)
{	
	bool isProperSub = any(r <- referenceLocations, locationAIsPartOfLocationB(toBeSubsumedLocation, r));
	
	bool isOverlapping = any(r <- referenceLocations, locationAIsOverlappingLocationB(toBeSubsumedLocation, r));

	return isProperSub || isOverlapping;
}

private bool locationAIsPartOfLocationB(loc a, loc b)
{
	int beginA = a.begin[0];
	int beginB = b.begin[0];
	int endA = a.end[0];
	int endB = b.end[0];
	
	return a.top == b.top && beginA >= beginB && beginA <= endB && endA <= endB;
}

private bool locationAIsOverlappingLocationB(loc a, loc b)
{
	int beginA = a.begin[0];
	int beginB = b.begin[0];
	int endA = a.end[0];
	int endB = b.end[0];
	
	bool AisSmallThanB = beginA >= beginB && endA <= endB;
	bool AisBiggerThanB = beginA <= beginB && endA >= endB;
	bool AstartsBeforeB = beginA <= beginB && endA >= beginB && endA <= endB;
	bool AstartsAfterB = beginA >= beginB && beginB <= endA && endA >= endB;
	
	return a.top == b.top && (AisSmallThanB || AisBiggerThanB || AstartsBeforeB || AstartsAfterB);
}


private set[node] generateNodesWithNRemovedStatements(int numberOfRemovedStatements, node n)
{
	list[node] returnList = [];

	top-down-break visit(n)
	{	
		case b:\block(statements) : 
		{	
			list[list[Statement]] subLists = allPossibleSublistsWithAMinimumNumberOfItems(statements, max(0, size(statements) - numberOfRemovedStatements));
			
			if (size(subLists) > 1)
			{
				for (sl <- subLists)
				{
					node temp = generateNewBlock(n, b, sl);

					returnList += temp;
				}
			}
					
			println("after block generation:<size(statements)>:<b@src>");							
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
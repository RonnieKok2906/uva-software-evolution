module type3::Subsumption

import Prelude;

import typeUtil::TypeUtil;

public map[node, set[loc]] subsumeCandidatesWhenPossibleType(map[node, set[loc]] candidates, map[node, set[node]] cutSubtrees)
{
	map[node, set[loc]] returnMap = ();
	println("Sorting..");
	list[node] sortedNodeList = sort(domain(candidates), bool(node a, node b){ return size(subtreesFromNode(a)) < size(subtreesFromNode(b)); });

	for (n <- sortedNodeList)
	{
		set[loc] tempLocations = candidates[n];
		
		candidates = candidates - (n:tempLocations);

		bool canBeSubsumed = any(r <- domain((candidates - returnMap)), nodesCanBeSubsumed(n, r, r in cutSubtrees ? cutSubtrees[r] : {}), locationsCanBeSubsumed(tempLocations, candidates[r]));
		
		if (!canBeSubsumed)
		{	
			returnMap += (n:tempLocations);
		}
		
		println("subsuming <size(sortedNodeList) - indexOf(sortedNodeList, n)> to go");
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
	
	return beginA >= beginB && beginA <= endB && endA <= endB;
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
	
	return (AisSmallThanB || AisBiggerThanB || AstartsBeforeB || AstartsAfterB);
}
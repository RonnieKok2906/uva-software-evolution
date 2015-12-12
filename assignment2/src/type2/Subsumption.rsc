module type2::Subsumption

import Prelude;

import typeUtil::TypeUtil;

public map[node, set[loc]] subsumeCandidatesWhenPossible(map[node, set[loc]] candidates)
{
	map[node, set[loc]] returnMap = ();
	
	list[node] sortedNodeList = sort(domain(candidates), bool(node a, node b){ return size(subtreesFromNode(a)) < size(subtreesFromNode(b)); });

	for (n <- sortedNodeList)
	{
		set[loc] tempLocations = candidates[n];
		
		candidates = candidates - (n:tempLocations);
	
		bool canBeSubsumed = any(r <- domain((candidates - returnMap)), nodesCanBeSubsumed(n, r), locationsCanBeSubsumed(tempLocations, candidates[r]));
		
		if (!canBeSubsumed)
		{	
			returnMap += (n:tempLocations);
		}
		
		println("after subsumption:<size(candidates)>");
	}
	
	return returnMap;
}

private bool locationsCanBeSubsumed(set[loc] toBeSubsumedLocations, set[loc] referenceLocations)
{
	return all(l <- toBeSubsumedLocations, locationCanBeSubsumed(l, referenceLocations));
}

private bool locationCanBeSubsumed(loc toBeSubsumedLocation, set[loc] referenceLocations)
{
	return any(r <- referenceLocations, locationAIsPartOfLocationB(toBeSubsumedLocation, r));
}

private bool locationAIsPartOfLocationB(loc a, loc b)
{
	int beginA = a.begin[0];
	int beginB = b.begin[0];
	int endA = a.end[0];
	int endB = b.end[0];
	
	return beginA >= beginB && beginA <= endB && endA <= endB;
}

private bool nodesCanBeSubsumed(node toBeSubsumedNode, node referenceNode)
{
	set[node] toBeSubsumedNodeSubtrees = {toBeSubsumedNode};
	set[node] referenceNodeSubtrees = subtreesFromNode(referenceNode);
	
	return toBeSubsumedNodeSubtrees < referenceNodeSubtrees;
}
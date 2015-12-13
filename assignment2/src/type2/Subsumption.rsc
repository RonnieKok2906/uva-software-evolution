module type2::Subsumption

import Prelude;
import util::Math;

import typeUtil::TypeUtil;
import model::CodeLineModel;
import type2::Config;

public map[int, list[list[CodeLine]]] subsumeCandidates(map[node, set[loc]] candidates, map[int, list[list[CodeLine]]] subblocks, CodeLineModel codeLineModel, Config config)
{
	map[int, list[list[CodeLine]]] transformedCandidates = transformCandidatesToCodeLines(candidates, codeLineModel);
		
	set[list[list[CodeLine]]] uniqueCodeFragments = range(transformedCandidates);
	
	transformedCandidates = (i:l[i] | i <- [0..size(uniqueCodeFragments)], l := toList(uniqueCodeFragments));

	int counter = newIdentifier(toList(domain(transformedCandidates)));

	for (s <- subblocks)
	{
		transformedCandidates[counter] = subblocks[s];
		counter += 1; 
	}

	list[int] sortedCandidatesOnClassSize = sortCandidatesOnCloneClassSize(transformedCandidates);	
	int numberOfBiggestCloneClass = size(sortedCandidatesOnClassSize) > 0 ? size(transformedCandidates[last(sortedCandidatesOnClassSize)]) : 0;

	
	if (numberOfBiggestCloneClass >= 2)
	{
		for (i <- [2..numberOfBiggestCloneClass + 1])
		{
			map[int, list[list[CodeLine]]] candidateWithEqualCloneClassSize = candidatesOfCloneClassSizeN(transformedCandidates, sortedCandidatesOnClassSize, i);
		
			list[int] sortedCandidatesOnLineSize = sortCandidatesOnLOC(candidateWithEqualCloneClassSize);
		
			map[int, list[list[CodeLine]]] subsumedCandidates = subsumeCandidatesDirectly(candidateWithEqualCloneClassSize, sortedCandidatesOnLineSize);

			sortedCandidatesOnClassSize = sortedCandidatesOnClassSize - toList(domain(candidateWithEqualCloneClassSize));
		
			transformedCandidates = transformedCandidates - candidateWithEqualCloneClassSize;
			transformedCandidates = transformedCandidates + subsumedCandidates;
		
		}
	}
	
	transformedCandidates = (r:transformedCandidates[r] | r <-transformedCandidates, size(transformedCandidates[r]) > 1);

	transformedCandidates = (r:transformedCandidates[r] | r <-transformedCandidates, any(cf <- transformedCandidates[r], size(cf) >= config.minimumNumberOfLines));

	return transformedCandidates;
}

private map[int, list[list[CodeLine]]] transformCandidatesToCodeLines(map[node, set[loc]] candidates, CodeLineModel codeLineModel)
{
	map[int, list[list[CodeLine]]] returnMap = ();
	
	int counter = 0;
	
	for (n <- candidates)
	{
		counter += 1;
		
		list[list[CodeLine]] cfs = [];
		
		for (location <- candidates[n])
		{
			cfs += [codeLinesForFragement(location, codeLineModel)];
		}
		
		returnMap[counter] = cfs;
	}
	
	return returnMap;
}

private map[int, list[list[CodeLine]]] candidatesOfCloneClassSizeN(map[int, list[list[CodeLine]]] candidates, list[int] sortedCandidates, int classSize)
{
	map[int, list[list[CodeLine]]] returnMap = ();
	
	for (i <- sortedCandidates)
	{
		list[list[CodeLine]] temp = candidates[i];
	
		if (size(temp) == classSize)
		{
			returnMap += (i:temp);
		}
	}
	
	return returnMap;
}

private list[int] sortCandidatesOnCloneClassSize(map[int, list[list[CodeLine]]] candidates)
{
	return sort(domain(candidates), bool(int a, int b){ return size(candidates[a]) < size(candidates[b]); });
}

private list[int] sortCandidatesOnLOC(map[int, list[list[CodeLine]]] candidates)
{
	return sort(domain(candidates), bool(int a, int b){ return biggestCodeFragment(candidates[a]) < biggestCodeFragment(candidates[b]); });
}

private int biggestCodeFragment(list[list[CodeLine]] cfs)
{	
	return (0 | max(it, size(onlyLinesWithCode(cf))) | cf <- cfs);
}

private map[int, list[list[CodeLine]]] subsumeCandidatesDirectly(map[int, list[list[CodeLine]]] candidates, list[int] sortedCandidates)
{
	if (size(sortedCandidates) <= 2)
	{
		return candidates;
	}

	int currentItem = sortedCandidates[0];
	list[list[CodeLine]] refCfs = candidates[currentItem];
	
	loopItems = tail(sortedCandidates);
	list[int] innerLoopItems = loopItems - loopItems[0];
	
	for (i <- loopItems)
	{	
		refCfs = candidates[i];
		
		innterLoopItems = innerLoopItems - [i];
	
		if (size(innterLoopItems) < 1)
		{
			break;
		}

		for (j <- innterLoopItems)
		{	
			if (j in candidates)
			{	
				list[list[CodeLine]] tempCfs = candidates[j];
	
				if (codeFragmentsACanBeSubsumedInCodeFragmentsB(refCfs, tempCfs))
				{
					candidates = candidates - (i:refCfs);	
					assert(size(refCfs) == size(tempCfs));
					innterLoopItems = innerLoopItems - [i];
				}
			}
		}
	}

	return candidates;
}

private int newIdentifier(list[int] identifiers)
{
	return (0 | max(it, i) | i <- identifiers) + 1;
}

private bool codeFragmentsACanBeSubsumedInCodeFragmentsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	return size(cfsA) == size(cfsB) && all(cf <- cfsA, codeFragmentCanBeSubsumedInCodeFragments(cf, cfsB));
}

private bool codeFragmentsACanPartiallyBeSubsumedInCodeFragmentsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	return size(cfsA) > size(cfsB) && size(codeFragmentsThatCanPartiallyBeSubsumedInCodeFragmentsB(cfsA, cfsB)) == size(cfsB);
}

private list[list[CodeLine]] codeFragmentsThatCanPartiallyBeSubsumedInCodeFragmentsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	return [cf | cf <- cfsA, codeFragmentCanBeSubsumedInCodeFragments(cf, cfsB)];
}

private bool codeFragmentCanBeSubsumedInCodeFragments(list[CodeLine] cfA, list[list[CodeLine]] cfs)
{
	return any(cfB <- cfs, codeFragmentCanBeSubsumed(cfA, cfB));
}

private bool codeFragmentCanBeSubsumed(list[CodeLine] cfA, list[CodeLine] cfB)
{
	return cfA[0].fileName == cfA[0].fileName && cfA&cfB == cfA;
}
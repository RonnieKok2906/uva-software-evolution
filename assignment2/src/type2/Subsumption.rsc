module type2::Subsumption

import Prelude;
import util::Math;

import typeUtil::TypeUtil;
import model::CodeLineModel;
import type2::Config;

public map[int, list[list[CodeLine]]] subsumeCandidates(map[node, set[loc]] candidates, map[int, list[list[CodeLine]]] subblocks, CodeLineModel codeLineModel, Config config)
{
	println("Transforming the candidates..");

	map[int, list[list[CodeLine]]] transformedCandidates = transformCandidatesToCodeLines(candidates, codeLineModel);
	
	int counter = newIdentifier(toList(domain(transformedCandidates)));

	for (s <- subblocks)
	{
		transformedCandidates[counter] = subblocks[s];
		counter += 1; 
	}

	transformedCandidates = removeTooSmallItems(transformedCandidates, config);
	
	list[int] sortedCandidatesOnClassSize = sortCandidatesOnCloneClassSize(transformedCandidates);	
	int numberOfBiggestCloneClass = size(sortedCandidatesOnClassSize) > 0 ? size(transformedCandidates[last(sortedCandidatesOnClassSize)]) : 0;

	transformedCandidates = (r:transformedCandidates[r] | r <- transformedCandidates, size(transformedCandidates[r]) > 1);
	
	if (numberOfBiggestCloneClass >= 2)
	{	
		for (i <- [2..numberOfBiggestCloneClass + 1])
		{		
			map[int, list[list[CodeLine]]] candidatesWithEqualCloneClassSize = candidatesOfCloneClassSizeN(transformedCandidates, sortedCandidatesOnClassSize, i);

			list[int] sortedCandidatesOnLineSize = sortCandidatesOnLOC(candidatesWithEqualCloneClassSize);
		
			map[int, list[list[CodeLine]]] subsumedCandidates = subsumeCandidates(candidatesWithEqualCloneClassSize, sortedCandidatesOnLineSize);

			sortedCandidatesOnClassSize = sortedCandidatesOnClassSize - toList(domain(candidatesWithEqualCloneClassSize));
		
			transformedCandidates = transformedCandidates - candidatesWithEqualCloneClassSize;
			transformedCandidates = transformedCandidates + subsumedCandidates;
			
			println("subsumptions to go:<numberOfBiggestCloneClass - i>");
		}
	}

	return transformedCandidates;
}

private map[int, list[list[CodeLine]]] removeTooSmallItems(map[int, list[list[CodeLine]]] candidates, Config config)
{
	map[int, list[list[CodeLine]]] returnMap = ();
	
	for (c <- candidates)
	{	
		bool hasEnoughLines = any( cf <- candidates[c], size([l| l <-cf, l.hasCode]) >= config.minimumNumberOfLines);
		
		if (hasEnoughLines)
		{
			returnMap[c] = toList(toSet(candidates[c]));
		}	
	}
	
	return returnMap;
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
		else if (size(temp) > classSize)
		{
			break;
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

private map[int, list[list[CodeLine]]] subsumeCandidates(map[int, list[list[CodeLine]]] candidates, list[int] sortedCandidates)
{
	if (size(sortedCandidates) < 2)
	{
		return candidates;
	}
	
	list[int] loopItems = sortedCandidates;
	list[int] innerLoopItems = tail(loopItems);
	
	map[int, list[list[CodeLine]]] candidatesToAdd = ();
	
	for (i <- loopItems)
	{	
		refCfs = candidates[i];
		
		innerLoopItems = innerLoopItems - [i];
		
		if (size(innerLoopItems) < 1)
		{
			break;
		}

		for (j <- innerLoopItems)
		{	
			if (j in candidates)
			{	
				list[list[CodeLine]] tempCfs = candidates[j];
	
				if (codeFragmentsACanBeSubsumedInCodeFragmentsB(refCfs, tempCfs))
				{
					candidates = candidates - (i:refCfs);
				}
				//else if (numberOfLinesRefCfs > 2)
				//{
				//	if (codeFragmentsAareAdjacentToCodeFragmentsB(refCfs, tempCfs))
				//	{
				//		candidates = candidates - (i:refCfs);
				//	
				//		candidates[j] = mergeCodeFragmentsAWithCodeFragmentsB(refCfs, tempCfs);	
				//	
				//		println("Is Adjacent");		
				//	}
				//}
				//
				//println("permutations:<size(refCfs)>");
			}
		}
	}

	return candidates;
}

private list[list[CodeLine]] mergeCodeFragmentsAWithCodeFragmentsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	for (p <-permutations(cfsA))
	{
		if (codeFragmentsAareAdjacentToCodeFragmentsBDirectly(p, cfsB))
		{
			return [mergeCodeFragments(cfsA[i], cfsB[i]) | i <- [0..size(cfsA) + 1]];
		}
	} 
	
	assert(false);
	return [];
}

private list[CodeLine] mergeCodeFragments(list[CodeLine] cfA, list[CodeLine] cfB)
{
	return sort(toSet(cfA + cfB), bool(CodeLine a, CodeLine b){ return a.lineNumber < a.lineNumber; });
}

private bool codeFragmentsAareAdjacentToCodeFragmentsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	return size(cfsA) == size(cfsB) && any(p <-permutations(cfsA), codeFragmentsAareAdjacentToCodeFragmentsBDirectly(cfsA, cfsB));
}

private bool codeFragmentsAareAdjacentToCodeFragmentsBDirectly(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	return all(i <- [0..size(cfsA) + 1], codeFragmentIsAdjacentToCodeFragment(cfsA[i], cfsB[i]));
}

private bool codeFragmentIsAdjacentToCodeFragment(list[CodeLine] cfA, list[CodeLine] cfB)
{
	if (cfA[0].fileName != cfB[0].fileName)
	{
		return false;
	}

	list[CodeLine] mergedLines = mergeCodeFragments(cfA, cfB);
	
	list[int] lineNumbers = [l.lineNumber | l <- mergedLines];
	
	return last(lineNumbers) - lineNumbers[0] == size(lineNumbers) - 1;
}

public int newIdentifier(list[int] identifiers)
{
	return (0 | max(it, i) | i <- identifiers) + 1;
}

private bool codeFragmentsACanBeSubsumedInCodeFragmentsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	return size(cfsA) == size(cfsB) && all(cf <- cfsA, codeFragmentCanBeSubsumedInCodeFragments(cf, cfsB));
}

private bool codeFragmentsACanPartiallyBeSubsumedInCodeFragmentsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	return size(cfsA) < size(cfsB) && size(codeFragmentsThatCanPartiallyBeSubsumedInCodeFragmentsB(cfsA, cfsB)) == size(cfsA);
}

private bool codeFragmentCanBeSubsumedInCodeFragments(list[CodeLine] cfA, list[list[CodeLine]] cfs)
{
	return any(cfB <- cfs, codeFragmentCanBeSubsumed(cfA, cfB));
}

private bool codeFragmentCanBeSubsumed(list[CodeLine] cfA, list[CodeLine] cfB)
{
	int sA = size(cfA);
	int sB = size(cfB);
	
	return cfA[0].fileName == cfA[0].fileName && sA <= sB && cfA[0].lineNumber >= cfB[0].lineNumber && cfA[sA - 1].lineNumber <= cfB[sB -1].lineNumber;
}
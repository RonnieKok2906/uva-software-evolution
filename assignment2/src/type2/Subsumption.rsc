module type2::Subsumption

import Prelude;
import util::Math;

import typeUtil::TypeUtil;
import model::CodeLineModel;
import type2::Config;

public map[int, list[list[CodeLine]]] subsumeCandidates(map[node, set[loc]] candidates, CodeLineModel codeLineModel, Config config)
{
	map[int, list[list[CodeLine]]] transformedCandidates = transformCandidatesToCodeLines(candidates, codeLineModel);
	
	set[list[list[CodeLine]]] uniqueCodeFragments = range(transformedCandidates);
	
	transformedCandidates = (i:l[i] | i <- [0..size(uniqueCodeFragments)], l := toList(uniqueCodeFragments));

	list[int] sortedCandidates = sortCandidates(transformedCandidates);

	map[int, list[list[CodeLine]]] intermediateResult = subsumeCandidatesDirectly(transformedCandidates, sortedCandidates);
	
	sortedCandidates = sortCandidates(intermediateResult);
	intermediateResult = subsumeWithAdjacent(intermediateResult, sortedCandidates, codeLineModel);
	
	intermediateResult = (r:intermediateResult[r] | r <-intermediateResult, size(intermediateResult[r]) > 1);

	//intermediateResult = (r:intermediateResult[r] | r <-intermediateResult, any(cf <- intermediateResult[r], size(cf) >= config.minimumNumberOfLines));

	return intermediateResult;
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

private list[int] sortCandidates(map[int, list[list[CodeLine]]] candidates)
{
	return sort(domain(candidates), bool(int a, int b){ return biggestCodeFragment(candidates[a]) < biggestCodeFragment(candidates[b]); });
}

private int biggestCodeFragment(list[list[CodeLine]] cfs)
{	
	return (0 | max(it, size(onlyLinesWithCode(cf))) | cf <- cfs);
}

private map[int, list[list[CodeLine]]] subsumeCandidatesDirectly(map[int, list[list[CodeLine]]] candidates, list[int] sortedCandidates)
{
	if (size(sortedCandidates) == 0)
	{
		return candidates;
	}

	int currentItem = sortedCandidates[0];
	list[list[CodeLine]] refCfs = candidates[currentItem];
	
	loopItems = tail(sortedCandidates);

	for (i <- loopItems)
	{
		list[list[CodeLine]] tempCfs = candidates[i];
	
		if (codeFragmentsACanBeSubsumedInCodeFragmentsB(refCfs, tempCfs))
		{
			candidates = candidates - (currentItem:refCfs);	
			
			sortedCandidates = tail(sortedCandidates);
		}
		else if (codeFragmentsACanPartiallyBeSubsumedInCodeFragmentsB(refCfs, tempCfs))
		{
			list[list[CodeLine]] partiallySubsumable = codeFragmentsThatCanPartiallyBeSubsumedInCodeFragmentsB(refCfs, tempCfs);
			
			candidates[currentItem] = refCfs - partiallySubsumable;
		}
	}
	
	return candidates;
}

private int newIdentifier(list[int] identifiers)
{
	return (0 | max(it, i) | i <- identifiers) + 1;
}

private map[int, list[list[CodeLine]]] subsumeWithAdjacent(map[int, list[list[CodeLine]]] candidates, list[int] sortedCandidates, CodeLineModel codeLineModel)
{
	println("subsume adjecent rest:<size(sortedCandidates)>");
	
	if (size(sortedCandidates) == 0)
	{
		return candidates;
	}

	int currentItem = sortedCandidates[0];
	list[list[CodeLine]] refCfs = candidates[currentItem];
	
	loopItems = tail(sortedCandidates);
	
	bool didMerge = false;
	
	for (i <- loopItems)
	{
		list[list[CodeLine]] tempCfs = candidates[i];
	
		if (codeFragmentsAareAdjacentToCodeFragementsB(refCfs, tempCfs, codeLineModel))
		{
			candidates[i] = mergeCodeFragmentsLists(refCfs, tempCfs, codeLineModel);

			candidates = candidates - (currentItem:refCfs);

			didMerge = true;

			break;
		}
		else if (codeFragmentsAarePartiallyAdjacentToCodeFragementsB(refCfs, tempCfs, codeLineModel))
		{
			list[list[CodeLine]] partiallySubsumable = codeFragmentsThatAarePartiallyAdjacentToCodeFragementsB(refCfs, tempCfs, codeLineModel);
			
			candidates[i] = mergeCodeFragmentsLists(partiallySubsumable, tempCfs, codeLineModel);

			int ni = newIdentifier(sortedCandidates);
			candidates[currentItem] = refCfs;
			candidates[ni] = refCfs - partiallySubsumable;
	
		}
	}
	
	if (didMerge)
	{
		sortedCandidates = sortCandidates(candidates);
	
		return subsumeWithAdjacent(candidates, sortedCandidates, codeLineModel);
	}
	
	sortedCandidates = size(sortedCandidates) > 0 ?  tail(sortedCandidates) : [];
	
	return subsumeWithAdjacent(candidates, sortedCandidates, codeLineModel);	
}

private list[list[CodeLine]] mergeCodeFragmentsLists(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB, CodeLineModel codeLineModel)
{
	return ([] | it + mergeCodeFragmentWithCodeFragments(cf, cfsB, codeLineModel) | cf <- cfsA);
}

private list[list[CodeLine]] mergeCodeFragmentWithCodeFragments(list[CodeLine] cfA, list[list[CodeLine]] cfs, CodeLineModel codeLineModel)
{
	for (cfB <- cfs)
	{
		if (codeFragmentIsAdjacentToCodeFragment(cfA, cfB, codeLineModel))
		{
			return [mergeCodeFragments(cfA, cfB)];	
		}
	}
	
	assert(false);
	return cfA;
}

private list[CodeLine] mergeCodeFragments(list[CodeLine] cfA, list[CodeLine] cfB)
{
	return sort(toList(toSet(cfA + cfB)), bool(CodeLine a, CodeLine b){ return a.lineNumber < b.lineNumber; });
}

private bool codeFragmentsAareAdjacentToCodeFragementsB(list[list[CodeLine]] cfA, list[list[CodeLine]] cfB, CodeLineModel codeLineModel)
{
	return size(cfA) == size(cfB) && all(cf <- cfA, codeFragmentIsAdjacentToOneOfCodeFragments(cf, cfB, codeLineModel));
}

private bool codeFragmentsAarePartiallyAdjacentToCodeFragementsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB, CodeLineModel codeLineModel)
{
	return size(cfsA) > size(cfsB) && size(codeFragmentsThatAarePartiallyAdjacentToCodeFragementsB(cfsA, cfsB, codeLineModel)) == size(cfsB);
}

private list[list[CodeLine]] codeFragmentsThatAarePartiallyAdjacentToCodeFragementsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB, CodeLineModel codeLineModel)
{
	return [cf | cf <- cfsA, codeFragmentIsAdjacentToOneOfCodeFragments(cf, cfsB, codeLineModel)];
}

private bool codeFragmentIsAdjacentToOneOfCodeFragments(list[CodeLine] cfA, list[list[CodeLine]] cfs, CodeLineModel codeLineModel)
{
	//return any(cfB <- cfs, codeFragmentIsAdjacentToCodeFragment(cfA, cfB, codeLineModel));
	
	bool returnValue = any(cfB <- cfs, codeFragmentIsAdjacentToCodeFragment(cfA, cfB, codeLineModel));

	//for (l <- cfA)
	//{
	//	//if (l.lineNumber == 43 || l.lineNumber == 38)
	//	//{
	//		//println("biggest:<biggestLineNumber>:smallest:<smallestLineNumber>:<size(restLines)>");
	//		println("38 or 43:<l.lineNumber>:<returnValue>");
	//		list[int] lineNumbers = [i.lineNumber | i <- cfB];
	//		println("A:< [i.lineNumber | i <- cfA]>:this:<lineNumbers>");
	//	//}
	//}

	return returnValue;
}

private bool codeFragmentIsAdjacentToCodeFragment(list[CodeLine] cfA, list[CodeLine] cfB, CodeLineModel codeLineModel)
{
	if (cfA[0].fileName != cfB[0].fileName)
	{
		return false;
	}
	
	loc fileName = cfA[0].fileName;
	
	list[CodeLine] sortedLines = sort(toList(toSet(cfA + cfB)), bool(CodeLine a, CodeLine b){ return a.lineNumber < b.lineNumber; });
	
	int smallestLineNumber = sortedLines[0].lineNumber;
	int biggestLineNumber = last(sortedLines).lineNumber;
	
	list[CodeLine] cmLines = [line | i <- [smallestLineNumber..biggestLineNumber], line := codeLineModel[fileName][i]];

	list[CodeLine] restLines = cmLines - sortedLines;
	
	bool returnValue = restLines == [] || all(l <- restLines, !l.hasCode);
	
	//for (l <- cfA)
	//{
	//	//if (l.lineNumber == 43 || l.lineNumber == 38)
	//	//{
	//		println("biggest:<biggestLineNumber>:smallest:<smallestLineNumber>:<size(restLines)>");
	//		println("38 or 43:<l.lineNumber>:<returnValue>");
	//		list[int] lineNumbers = [i.lineNumber | i <- cfB];
	//		println("A:< [i.lineNumber | i <- cfA]>:this:<lineNumbers>");
	//	//}
	//}
	
	return returnValue;
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
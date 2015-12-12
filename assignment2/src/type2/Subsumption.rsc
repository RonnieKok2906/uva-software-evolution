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

	//sortedCandidates = sortCandidates(intermediateResult);
	//intermediateResult = subsumeCandidatesDirectly(intermediateResult, sortedCandidates);

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
		
		for (l <- candidates[n])
		{
			cfs += [codeLinesForFragement(l, codeLineModel)];
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
	map[int, list[list[CodeLine]]] returnMap = ();
	
	map[int, list[list[CodeLine]]] cs = candidates;
	
	for (i <- sortedCandidates)
	{
		list[list[CodeLine]] tempFragments = cs[i];
		
		cs = cs - (i:tempFragments);
	
		bool canBeDirectlySubsumed = any(r <- domain(cs), codeFragmentsACanBeSubsumedInCodeFragmentsB(tempFragments, cs[r]));
		
		if (!canBeDirectlySubsumed)
		{	
			returnMap += (i:tempFragments);
		}
		else
		{
			sortedCandidates = sortedCandidates - i;
		}
		
		println("subsume direct rest:<size(candidates)>");
	}

	return returnMap;
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
	
	for (i <- sortedCandidates)
	{
		list[list[CodeLine]] tempCfs = candidates[i];
	
		if (codeFragmentsAareAdjacentToCodeFragementsB(refCfs, tempCfs, codeLineModel))
		{
			candidates[i] = mergeCodeFragmentsLists(refCfs, tempCfs, codeLineModel);
		}
		else if (codeFragmentsAareAdjacentToCodeFragementsB(tempCfs, refCfs, codeLineModel))
		{
			candidates[currentItem] = mergeCodeFragmentsLists(tempCfs, refCfs, codeLineModel);
			sortedCandidates = sortedCandidates - [i];
			candidates = candidates - (i:tempCfs);

			didMerge = true;
		}	
	}
	
	if (didMerge)
	{
		return subsumeWithAdjacent(candidates, sortedCandidates, codeLineModel);
	}
	
	if (size(sortedCandidates) > 1)
	{
		sortedCandidates = tail(sortedCandidates);
	
		return subsumeWithAdjacent(candidates, sortedCandidates, codeLineModel);
	}
	
	return candidates;	
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
	return all(cf <- cfA, codeFragmentIsAdjacentToOneOfCodeFragments(cf, cfB, codeLineModel));
}

private bool codeFragmentIsAdjacentToOneOfCodeFragments(list[CodeLine] cfA, list[list[CodeLine]] cfs, CodeLineModel codeLineModel)
{
	return any(cfB <- cfs, codeFragmentIsAdjacentToCodeFragment(cfA, cfB, codeLineModel));
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
		
	return returnValue;
}

private bool codeFragmentsACanBeSubsumedInCodeFragmentsB(list[list[CodeLine]] cfsA, list[list[CodeLine]] cfsB)
{
	return all(cf <- cfsA, codeFragmentCanBeSubsumedInCodeFragments(cf, cfsB));
}

private bool codeFragmentCanBeSubsumedInCodeFragments(list[CodeLine] cfA, list[list[CodeLine]] cfs)
{
	return any(cfB <- cfs, codeFragmentCanBeSubsumed(cfA, cfB));
}

private bool codeFragmentCanBeSubsumed(list[CodeLine] cfA, list[CodeLine] cfB)
{
	return cfA[0].fileName == cfA[0].fileName && cfA&cfB == cfA;
}
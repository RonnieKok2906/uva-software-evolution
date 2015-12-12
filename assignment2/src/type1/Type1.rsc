module type1::Type1

import model::CodeLineModel;
import model::CloneModel;
import type1::Type1Config;
import Prelude;
import ListRelation;
import util::Math;
import IO;


alias CodeBlock = list[CodeLine];
alias DuplicationMap = map[list[str], set[CodeBlock]];


public CloneModel clonesRec(CodeLineModel model) 
{
	int lineThreshold = LineThreshold;
	model = removeEmptyLinesAndAssignOrderNumber(model);
	
	// Initial run
	DuplicationMap duplicationsMap = clonesInProject(model, lineThreshold);

	int nrOfClones = nrOfClonesInDuplicationMap(duplicationsMap);
	int nrOfCloneClasses = size(duplicationsMap);

	println("Found <nrOfClones> in <nrOfCloneClasses> clone classes.");

	while (nrOfClones > 0)
	{
		lineThreshold += 1;

		largerDuplicationsMap = clonesInProject(model, lineThreshold);

		nrOfClones = nrOfClonesInDuplicationMap(largerDuplicationsMap);
		nrOfCloneClasses = size(largerDuplicationsMap);

		println("Found <nrOfClones> in <nrOfCloneClasses> clone classes.");
		
		duplicationsMap = mergeDuplicationMaps(duplicationsMap, largerDuplicationsMap);
	}

	nrOfClones = nrOfClonesInDuplicationMap(duplicationsMap);
	nrOfCloneClasses = size(duplicationsMap);

	println("Search complete");
	println("Found <nrOfClones> in <nrOfCloneClasses> clone classes.");
	
	return createCloneModel(duplicationsMap);
}

public int nrOfClonesInDuplicationMap(DuplicationMap duplicationMap) 
{
	return (0 | it + size(duplicationMap[k]) | k <- duplicationMap);
}

public DuplicationMap mergeDuplicationMaps(DuplicationMap map1, DuplicationMap map2) 
{
	// Remove clone classes that are a sub set of clones classes from map2.
	DuplicationMap map3 = (key : map1[key] | key <- map1, !isSubSetOf(map1[key], map2));

	int discardedClones = nrOfClonesInDuplicationMap(map1) - nrOfClonesInDuplicationMap(map3);
	int discardedCloneClasses = size(map1) - size(map3);

	println("Discarded <discardedClones> clones and <discardedCloneClasses> clone classes.");

	return map3 + map2;
} 


public bool isSubSetOf(set[CodeBlock] blocks, DuplicationMap duplicationsMap) 
{
	return any(k <- duplicationsMap, isSubSetOf(blocks, duplicationsMap[k]));
}

public bool isSubSetOf(set[CodeBlock] blocks1, set[CodeBlock] blocks2) 
{
	if(size(blocks1) == 0) return true;

	tuple[CodeBlock, set[CodeBlock]] takeonFromResult = takeOneFrom(blocks1);
	CodeBlock head = takeonFromResult[0];
	set[CodeBlock] tail = takeonFromResult[1];

	return isElemOf(head, blocks2) && isSubSetOf(tail, blocks2);
}

public bool isElemOf(CodeBlock block, set[CodeBlock] blocks) 
{
	return any(block1 <- blocks, isSubBlockOf(block, block1));
}

public bool isSubBlockOf(CodeBlock block1, CodeBlock block2) 
{
	return block1[0].fileName == block2[0].fileName
		&& minLineNumber(block1) >= minLineNumber(block2)
		&& maxLineNumber(block1) <= maxLineNumber(block2);
}

public int minLineNumber(CodeBlock block) 
{
	int minLineNumber = block[0].lineNumber;
	for(CodeLine line <- block) 
	{
		if(line.lineNumber < minLineNumber) 
		{
			minLineNumber = line.lineNumber;
		}
	}
	return minLineNumber;
}

public int maxLineNumber(CodeBlock block) 
{
	int maxLineNumber = block[0].lineNumber;
	for(CodeLine line <- block) 
	{
		if(line.lineNumber > maxLineNumber) 
		{
			maxLineNumber = line.lineNumber;
		}
	}
	return maxLineNumber;
}

public DuplicationMap clonesInProject(CodeLineModel model, int lineThreshold)
{	
	println("Code fragment line threshold: <lineThreshold>");
	map[list[str], set[CodeBlock]] mapping = indexAllPossibleCodeFragmentsOfNLines(model, lineThreshold);
	println("Number of all possible code fragments: <size(mapping)>");

	map[list[str], set[CodeBlock]] duplicationsMap = (cf : mapping[cf] | list[str] cf <- mapping,  size(mapping[cf]) > 1);

	return duplicationsMap;
}

public CloneModel createCloneModel(DuplicationMap duplicationsMap)
{
	CloneModel cloneModel = ();
	
	int cloneId = 1;
	int cloneClassId = 1;
	
	for(k <- duplicationsMap) 
	{
		CloneClass cloneClass = [];
		
		for(c <- duplicationsMap[k]) 
		{
            cloneClass += clone(cloneClassId, cloneId, c[0].fileName, c);
            cloneId += 1;		
		}
	
		cloneModel += (cloneClassId : cloneClass);
		cloneClassId += 1;
	}
	return cloneModel;
}

private map[list[str], set[CodeBlock]] indexAllPossibleCodeFragmentsOfNLines(CodeLineModel model, int nrOfLines)
{	
	lrel[list[str], CodeBlock] blocks = ([] | it + allDuplicateCandidatesOfNLinesFromFile(sortedLinesForCompilationUnit(f, model), nrOfLines) | f <- model);

	return ListRelation::index(blocks);
}

private lrel[list[str], CodeBlock] allDuplicateCandidatesOfNLinesFromFile(list[CodeLine] lines, int nrOfLinesInBlock)
{	
	if (size(lines) < nrOfLinesInBlock) return [];
	
	lrel[list[str], list[CodeLine]] blocks = [];
	
	for (i <- [0..size(lines)-nrOfLinesInBlock + 1])
	{
		list[CodeLine] linesInBlock = [l | l <- lines[i..i+nrOfLinesInBlock]];
		
		list[str] codeFragments = [l.codeFragment | l <- linesInBlock];
		
		blocks += [<codeFragments, linesInBlock>];
	}
	
	return blocks;
}


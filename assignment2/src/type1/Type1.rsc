module type1::Type1

import model::CodeLineModel;
import model::CloneModel;
import type1::Config;
import Prelude;
import ListRelation;
import util::Math;
import IO;


alias CodeBlock = list[CodeLine];
alias DuplicationMap = map[list[str], set[CodeBlock]];


public CloneModel clonesInProject(CodeLineModel model, Config config) 
{
	int lineThreshold = config.minimumNumberOfLines;
	println("Configured clone size threshold: <lineThreshold>");

	int modelSize = (0 | it + size(model[compilationUnit]) | loc compilationUnit <- model );
	println("Code line model size: <modelSize> lines");
	
	model = removeEmptyLines(model);
	modelSize = (0 | it + size(model[compilationUnit]) | loc compilationUnit <- model );
	println("Empty lines removed from code line model. Shrunk to <modelSize> lines."); 
	
	// Initial run
	DuplicationMap duplicationMap = clonesInProject(model, lineThreshold);

	DuplicationMap unmergable = ();

	int nrOfClones = nrOfClonesInDuplicationMap(duplicationMap);
	int nrOfCloneClasses = size(duplicationMap);

	println("Found <nrOfCloneClasses> classes with <nrOfClones> <lineThreshold>-line clones.");

	while (nrOfClones > 0)
	{
		lineThreshold += 1;

		largerDuplicationMap = clonesInProject(model, lineThreshold);

		nrOfClones = nrOfClonesInDuplicationMap(largerDuplicationMap);
		nrOfCloneClasses = size(largerDuplicationMap);

		println("Found <nrOfCloneClasses> classes with <nrOfClones> <lineThreshold>-line clones.");
		
		println("Merging <size(duplicationMap)> classes of \<= <lineThreshold -1>-line clones into <nrOfCloneClasses> classes of <lineThreshold>-line clones.");
		unmergable += mergeDuplicationMaps(duplicationMap, largerDuplicationMap);
		
		duplicationMap = largerDuplicationMap;
	}

	duplicationMap = duplicationMap + unmergable;

	nrOfClones = nrOfClonesInDuplicationMap(duplicationMap);
	nrOfCloneClasses = size(duplicationMap);

	println("Search complete");
	println("Found <nrOfClones> clones in <nrOfCloneClasses> clone classes.");
	
	return createCloneModel(duplicationMap);
}


public DuplicationMap clonesInProject(CodeLineModel model, int lineThreshold)
{	
	map[list[str], set[CodeBlock]] mapping = indexAllPossibleCodeFragmentsOfNLines(model, lineThreshold);

	return (cf : mapping[cf] | list[str] cf <- mapping,  size(mapping[cf]) > 1);
}


public int nrOfClonesInDuplicationMap(DuplicationMap duplicationMap) 
{
	return (0 | it + size(duplicationMap[k]) | k <- duplicationMap);
}

public DuplicationMap mergeDuplicationMaps(DuplicationMap map1, DuplicationMap map2) 
{
	// Remove clone classes that are a sub set of clones classes from map2.
	return (key : map1[key] | key <- map1, !isSubSetOf(map1[key], map2));
} 

public bool isSubSetOf(set[CodeBlock] blocks, DuplicationMap duplicationsMap) 
{
	return any(k <- duplicationsMap, isSubSetOf(blocks, duplicationsMap[k]));
}

public bool isSubSetOf(set[CodeBlock] blocks1, set[CodeBlock] blocks2) 
{
	if(size(blocks1) > size(blocks2)) return false;

	CodeBlock codeBlock = takeOneFrom(blocks1)[0];

	return any(block1 <- blocks2, isSubBlockOf(codeBlock, block1));
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

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


public CloneModel clonesRec(CodeLineModel model) 
{
	int lineThreshold = defaultConfiguration.minimumNumberOfLines;

	int modelSize = (0 | it + size(model[compilationUnit]) | loc compilationUnit <- model );
	println("Code line model size: <modelSize> lines");
	
	model = removeEmptyLines(model);
	modelSize = (0 | it + size(model[compilationUnit]) | loc compilationUnit <- model );
	println("Empty lines removed from code line model. Shrunk to <modelSize> lines."); 
	
	// Initial run
	DuplicationMap duplicationMap = clonesInProject(model, lineThreshold);

	int nrOfClones = nrOfClonesInDuplicationMap(duplicationMap);
	int nrOfCloneClasses = size(duplicationMap);

	println("Found <nrOfClones> in <nrOfCloneClasses> clone classes.");

	// Remove lines from code line model that are never duplicated.
	model = removeNonDuplicateLines(model, duplicationMap);
	modelSize = (0 | it + size(model[compilationUnit]) | loc compilationUnit <- model );
	println("Non duplicate lines removed from code line model. Shrunk to <modelSize> lines."); 

	while (nrOfClones > 0)
	{
		lineThreshold += 1;

		largerDuplicationMap = clonesInProject(model, lineThreshold);

		nrOfClones = nrOfClonesInDuplicationMap(largerDuplicationMap);
		nrOfCloneClasses = size(largerDuplicationMap);

		println("Found <nrOfClones> in <nrOfCloneClasses> clone classes.");
		
		duplicationMap = mergeDuplicationMaps(duplicationMap, largerDuplicationMap);
	}

	nrOfClones = nrOfClonesInDuplicationMap(duplicationMap);
	nrOfCloneClasses = size(duplicationMap);

	println("Search complete");
	println("Found <nrOfClones> in <nrOfCloneClasses> clone classes.");
	
	return createCloneModel(duplicationMap);
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

public CodeLineModel removeNonDuplicateLines(CodeLineModel codeLineModel, DuplicationMap duplicationMap) 
{
	int total = (0 | it + size(codeLineModel[compilationUnit]) | loc compilationUnit <- codeLineModel );

	println("Start removing non-duplicate lines from code line model.");
	int totalLines = 0;
	int linesReturned = 0;
	
	lineMap = flatten(duplicationMap);

	for (f <- codeLineModel)
	{
		map[int, CodeLine] lines = codeLineModel[f];
		map[int, CodeLine] linesToReturn = ();
		
		for (lineNumber <- lines)
		{
			if (f in lineMap && lineNumber in lineMap[f])
			{
				linesToReturn[lineNumber] = lines[lineNumber];
			}
		}
		
		totalLines += size(lines);
		linesReturned += size(linesToReturn);
		
		codeLineModel[f] = linesToReturn;
	}
	return codeLineModel;
}


public map[loc,list[int]] flatten(DuplicationMap duplicationMap) 
{
	return ( file : lineNumbersFromDuplicationMap(duplicationMap, file) | file <- filesFromDuplicationMap(duplicationMap));
}


private set[loc] filesFromDuplicationMap(DuplicationMap duplicationMap) 
{
	set[loc] files = {};

	for(key <- duplicationMap) 
	{
		set[CodeBlock] codeBlocks = duplicationMap[key];
		
		for(codeBlock <- codeBlocks) 
		{
			for(codeLine <- codeBlock) 
			{
				if(codeLine.fileName notin files) 
				{
					files += codeLine.fileName;
				} 
			}
		} 
	}
	return files;
}

private list[int] lineNumbersFromDuplicationMap(DuplicationMap duplicationMap, loc file) 
{
	list[int] lineNumbers = [];

	for(key <- duplicationMap) 
	{
		set[CodeBlock] codeBlocks = duplicationMap[key];
		
		for(codeBlock <- codeBlocks) 
		{
			for(codeLine <- codeBlock) 
			{
				if(codeLine.fileName == file) 
				{
					lineNumbers += codeLine.lineNumber;
				} 
			}
		} 
	}
	return lineNumbers;
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

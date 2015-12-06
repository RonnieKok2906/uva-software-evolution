module type1::Type1

import model::CodeLineModel;
import model::CloneModel;
import type1::Type1Config;
import Prelude;
import ListRelation;
import util::Math;
import IO;


alias CodeFragment = str;
alias CodeBlock = list[CodeLine];


public CloneModel clonesInProject(CodeLineModel model)
{	
	println("Code fragment line threshold: <LineThreshold>");
	map[list[str], set[CodeBlock]] mapping = indexAllPossibleCodeFragmentsOfNLines(model, LineThreshold);
	println("Number of all possible code fragments: <size(mapping)>");

	map[list[str], set[CodeBlock]] duplicationsMap = (cf : mapping[cf] | list[str] cf <- mapping,  size(mapping[cf]) > 1);
	
	int nrOfClones = (0 | it + size(duplicationsMap[k]) | k <- duplicationsMap);
	
	println("Number of clones: <nrOfClones>");
	println("Number of clone classes: <size(duplicationsMap)>");

	CloneModel cloneModel = ();
	
	int cloneId = 1;
	int cloneClassId = 1;
	
	for(k <- duplicationsMap) 
	{
		CloneClass cloneClass = [];
		
		for(clone <- duplicationsMap[k]) 
		{
            cloneClass += <cloneClassId, cloneId, clone>;
            cloneId += 1;		
		}
	
		cloneModel += (cloneClassId : cloneClass);
		cloneClassId += 1;
	}

	list[loc] files = getFilesFromCloneModel(cloneModel);
	
	println("Files:");
	for(file <- files) 
	{ 
	    println("<file>"); 
	}


	return cloneModel;
}

private map[list[CodeFragment], set[CodeBlock]] indexAllPossibleCodeFragmentsOfNLines(CodeLineModel model, int nrOfLines)
{	
	lrel[list[CodeFragment], CodeBlock] blocks = ([] | it + allDuplicateCandidatesOfNLinesFromFile(model[f], nrOfLines) | f <- model);

	return ListRelation::index(blocks);
}


private lrel[list[CodeFragment], CodeBlock] allDuplicateCandidatesOfNLinesFromFile(list[CodeLine] lines, int nrOfLinesInBlock)
{	
	if (size(lines) < nrOfLinesInBlock) return [];
	
	lrel[list[CodeFragment], list[CodeLine]] blocks = [];
	
	for (i <- [0..size(lines)-nrOfLinesInBlock + 1])
	{
		list[CodeLine] linesInBlock = [l | l <- lines[i..i+nrOfLinesInBlock]];
		
		list[CodeFragment] codeFragments = [l.codeFragment | l <- linesInBlock];
		
		blocks += [<codeFragments, linesInBlock>];
	}
	
	return blocks;
}


module type1::Type1

import model::CodeLineModel;
import model::CloneModel;

import Prelude;
import ListRelation;
import util::Math;
import IO;


alias CodeFragment = str;
alias CodeBlock = list[CodeLine];


public CloneModel clonesInProject(CodeLineModel model)
{	
	map[list[str], set[CodeBlock]] mapping = indexAllPossibleCodeFragmentsOfNLines(model, 6);
	
	map[list[str], set[CodeBlock]] duplicationsMap = (cf : mapping[cf] | list[str] cf <- mapping,  size(mapping[cf]) > 1);

	CloneModel cloneModel = ();
	
	int cloneId = 1;
	int cloneClassId = 1;
	
	for(k <- duplicationsMap) 
	{
		CloneClass cloneClass = [];
		
		for(clone <- duplicationsMap[k]) 
		{
            cloneClass += <cloneId, clone>;
            cloneId += 1;		
		}
	
		cloneModel += (cloneClassId : cloneClass);
	
		cloneClassId += 1;
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


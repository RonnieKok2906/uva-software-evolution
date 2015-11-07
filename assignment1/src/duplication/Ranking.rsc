module duplication::Ranking

import List;
import Set;
import String;
import ListRelation;
import IO;

import lang::java::jdt::m3::AST;

import MetricTypes;

import volume::Volume;


//TODO: implement
public Rank projectDuplication(set[Declaration] declarations)
{
	return neutral();
}

//TODO: implement
public map[list[CodeFragment], set[loc]] duplicationsInProject(set[Declaration] declarations)
{
	set[loc] files = toSet(getFilesFromASTs(declarations));
	
	mapping = indexAllCodeFragments(declarations);
	
	return (cf : mapping[cf] | list[CodeFragment] cf <- mapping,  size(mapping[cf]) > 1);
}

public lrel[list[CodeFragment], loc] allPossibleCodeFragmentsOfNLinesFromFile(loc file, int nrOfLinesInBlock)
{
	list[str] stringLines = readFileLines(file);
	
	lrel[list[CodeFragment], loc] blocks = [];
	
	for (i <- [0..size(stringLines)])
	{
		list[CodeFragment] cfs = stringLines[i..i + nrOfLinesInBlock];
		loc blockFile = file(0, 0, <i, 0>, <i + nrOfLinesInBlock, 0>);
		blocks += [<cfs, blockFile>];
		
	}
	
	return blocks;
}

public map[list[CodeFragment], set[loc]] indexAllCodeFragments(set[Declaration] declarations)
{
	list[loc] files = getFilesFromASTs(declarations);
	
	lrel[list[CodeFragment], loc] blocks = ([] | it + allPossibleCodeFragmentsOfNLinesFromFile(b, 6) | b <- files);

	return ListRelation::index(blocks);
}
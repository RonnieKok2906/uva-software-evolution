module duplication::Ranking

import Prelude;

import ListRelation;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import model::MetricTypes;
import model::CodeLineModel;

import volume::Volume;

alias CodeFragment = str;
alias CodeBlock = list[CodeLine];

alias DuplicationMetric = tuple[LOC duplicatedLines, LOC totalLines];

//Public Functions

public DuplicationMetric projectDuplication(CodeLineModel model)
{
	LOC numberOfDuplicatedLines = size(duplicationsInProject(model));
	LOC numberOfTotalLines = projectVolume(model);
	real percentage = 100 * toReal(numberOfDuplicatedLines) / toReal(numberOfTotalLines);
	
	return <numberOfDuplicatedLines, numberOfTotalLines>;
}


public Rank convertPercentageToRank(DuplicationMetric result) = plusPlus()
	when percentageConformsToRank(result, plusPlus());
public Rank convertPercentageToRank(DuplicationMetric result) = plus()
	when percentageConformsToRank(result, plus());
public Rank convertPercentageToRank(DuplicationMetric result) = neutral()
	when percentageConformsToRank(result, neutral());
public Rank convertPercentageToRank(DuplicationMetric result) = minus()
	when percentageConformsToRank(result, minus());
public Rank convertPercentageToRank(DuplicationMetric result) = minusMinus();


public void printDuplication(DuplicationMetric result)
{
	LOC duplicatedLOC = result.duplicatedLines;
	LOC totalLOC = result.totalLines;
	
	real percentage = 100.0 * toReal(duplicatedLOC) / toReal(totalLOC);
	
	println("DUPLICATION");
	
	println();
	println("---------------------------------------------");
	println("Rank\tDuplication");
	println("---------------------------------------------");
	for (r <- ranks)
	{
		println("<convertRankToString(r)> \t| <thresholdDuplicationPercentage[r].from * 100.0> - <thresholdDuplicationPercentage[r].to * 100.0> %");
	}
	
	
	println("---------------------------------------------");
	println("Number of duplicated lines: <duplicatedLOC>");
	println("Number of total number of lines: <totalLOC>");
	println("Percentage of duplicated lines: <percentage>%");
	println("Result: <convertRankToString(convertPercentageToRank(result))>");
	println("---------------------------------------------");
	println();
	println();
}


//Private Functions

private set[CodeLine] duplicationsInProject(CodeLineModel model)
{	
	map[list[CodeFragment], set[CodeBlock]] mapping = indexAllPossibleCodeFragmentsOfNLines(model, 6);
	
	map[list[CodeFragment], set[CodeBlock]] duplicationsMap = (cf : mapping[cf] | list[CodeFragment] cf <- mapping,  size(mapping[cf]) > 1);
	
	set[CodeLine] duplicatedLines = {};
	
	for (dm <- duplicationsMap)
	{
		set[CodeBlock] setOfCodeBlocks = duplicationsMap[dm];
		
		for (codeBlock <- setOfCodeBlocks)
		{
			for (codeLine <- codeBlock)
			{
				duplicatedLines += codeLine;
			}
		}
	}
	
	return duplicatedLines;
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


private map[Rank, tuple[real from, real to]] thresholdDuplicationPercentage = (
																				plusPlus() : <0.0, 0.03>,
																				plus() : <0.03, 0.05>,
																				neutral() : <0.05, 0.1>,
																				minus() : <0.1, 0.2>,
																				minusMinus() : <0.2, 1.0>
																				);

private bool percentageConformsToRank(DuplicationMetric result, Rank rank)
{	
	return 100.0 * (toReal(result.duplicatedLines) / toReal(result.totalLines)) <= (thresholdDuplicationPercentage[rank].to * 100.0);
}

public LOC numberOfDuplicatedLines(CodeLineModel model)
{
	return size(duplicationsInProject(model));
}


//Tests

public list[bool] allTests() = [
								testSourceIsDuplicated(),
								testSourceIsMinusMinus()
								]; 

test bool testSourceIsDuplicated()
{
	loc testProject = |project://testSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	CodeLineModel model = createCodeLineModel(m3Model);
	
	set[CodeLine] duplicateLines = duplicationsInProject(model);
	
	return size(duplicateLines) == 154 && projectVolume(model) == 158;
}

test bool testSourceIsMinusMinus()
{
	loc testProject = |project://testSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	CodeLineModel model = createCodeLineModel(m3Model);
	
	DuplicationMetric result = projectDuplication(model);
	
	return convertPercentageToRank(result) == minusMinus();
}
module Conversion

import Prelude;

import util::Math;

import model::MetricTypes;

//Public functions

//Calculate the average Rank of a list of SourceProperty rankings
public Rank averageRankOfPropertyRankings(list[SourceCodeProperty] properties)
{
	list[int] ranksToInts = mapper(properties, int (SourceCodeProperty sp){ return convertRankToInt(sp.rank);});
	real summedRanks = toReal(sum(ranksToInts));
	real numberOfItems = toReal(size(properties));
	
	return convertRealToRank(summedRanks / numberOfItems);
}

public void printMaintainability(MaintainabilityResult result)
{
	str volumeResult = convertRankToString(result.volume.rank);
	str complexityResult = convertRankToString(result.complexity.rank);
	str duplicationResult = convertRankToString(result.duplication.rank);
	str unitSizeResult = convertRankToString(result.unitSize.rank);
	str unitTestingResult = convertRankToString(result.unitTesting.rank);

	Rank analysabilityRank = averageRankOfPropertyRankings([result.volume, result.duplication, result.unitSize]);
	Rank changeabilityRank = averageRankOfPropertyRankings([result.complexity, result.duplication]);
	Rank stabilityRank = undefined();
	Rank testabilityRank = averageRankOfPropertyRankings([result.complexity, result.unitSize]);

	println("MAINTAINABILITY");
	println();

	println("\t\t| Volume\t| Complexity\t| Duplication\t| UnitSize\t| UnitTesting\t|| Result");
	println("------------------------------------------------------------------------------------------------------------");
	for (m <- maintainabilityMetrics)
	{
		str metric = convertMaintainabilityToString(m);
		
		switch (m)
		{
			case analysability() : println("<metric>\t| <volumeResult>\t\t| \t\t| <duplicationResult>\t\t| <unitSizeResult>\t\t| <unitTestingResult>\t|| <convertRankToString(analysabilityRank)>");
			case changeability() : println("<metric>\t| \t\t| <complexityResult>\t\t| <duplicationResult>\t\t| \t\t| \t\t|| <convertRankToString(changeabilityRank)>");
			case stability() : println("<metric>\t| \t\t| \t\t| \t\t| \t\t| <unitTestingResult>\t|| <convertRankToString(stabilityRank)>");
			case testability() : println("<metric>\t| \t\t| <complexityResult>\t\t| \t\t| <unitSizeResult>\t\t| <unitTestingResult>\t|| <convertRankToString(testabilityRank)>");
		}
	}
	println("------------------------------------------------------------------------------------------------------------");
	println();
	

	//println(maintainabiltiy);
}

//Private Functions

//Conversion from an enumerated Rank to an integer
private int convertRankToInt(Rank r)
{
	switch (r)
	{
		case plusPlus(): return 2;
		case plus() : return 1;
		case neutral() : return 0;
		case minus() : return -1;
		case minusMinus() : return -2;
		case undefined() : return -100000;
	}
}

//Conversion from a real to an enumerated Rank
private Rank convertRealToRank(real r) = plusPlus() when r > 1.5;
private Rank convertRealToRank(real r) = plus() when r > 0.5;
private Rank convertRealToRank(real r) = neutral() when r >= -0.5;
private Rank convertRealToRank(real r) = minus() when r >= -1.5;
private default Rank convertRealToRank(real r) = minusMinus();


public list[bool] allTests() = [
								average1(),
								average2(),
								average3(),
								average4(),
								convertToTwo(),
								convertToOne(),
								convertToZero(),
								convertToMinusOne(),
								convertToMinusTwo(),
								convertRealToPlusPlus(),
								convertRealToPlus(),
								convertRealToNeutral() ,
								convertRealToMinus(),
								convertRealToMinusMinus()
								];

//Tests
//Test cases are extracted from figure 5 in "A Practical Model for Measuring Maintainability", http://dx.doi.org/10.1109/QUATIC.2007.8
test bool average1() = averageRankOfPropertyRankings([
														volume(plusPlus()), 
														duplication(minus()), 
														unitSize(minus()), 
														unitTesting(neutral())
													]) == neutral();
														
test bool average2() = averageRankOfPropertyRankings([
														complexityPerUnit(minusMinus()), 
														duplication(minus())
													]) == minus();
													
test bool average3() = averageRankOfPropertyRankings([unitTesting(neutral())]) == neutral();
test bool average4() = averageRankOfPropertyRankings([
														complexityPerUnit(minusMinus()),
														unitSize(minus()),
														unitTesting(neutral())
													]) == minus();



test bool convertToTwo() = convertRankToInt(plusPlus()) == 2;
test bool convertToOne() = convertRankToInt(plus()) == 1;
test bool convertToZero() = convertRankToInt(neutral()) == 0;
test bool convertToMinusOne() = convertRankToInt(minus()) == -1;
test bool convertToMinusTwo() = convertRankToInt(minusMinus()) == -2;


test bool convertRealToPlusPlus() = all(x <- [1.55, 1.6..3], convertRealToRank(x) == plusPlus());
test bool convertRealToPlus() = all(x <- [0.55, 0.6..1.55], convertRealToRank(x) == plus());
test bool convertRealToNeutral() = all(x <- [-0.5, -0.45..0.55], convertRealToRank(x) == neutral());
test bool convertRealToMinus() = all(x <- [-1.5, -1.45..-0.5], convertRealToRank(x) == minus());
test bool convertRealToMinusMinus() = all(x <- [-3.45, -3.4..-1.5], convertRealToRank(x) == minusMinus());
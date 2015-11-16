module Conversion

import Prelude;
import util::Math;
import model::MetricTypes;

//Public functions

//Take the median Rank of a list of SourceProperty rankings
public Rank medianRankOfPropertyRankings(list[SourceCodeProperty] properties)
{
	list[int] ranksToInts = mapper(properties, int (SourceCodeProperty sp){ return convertRankToInt(sp.rank);});
	
	list[int] sortedRanks = sort(ranksToInts);
	
	listSize = size(properties);
	
	int position = 0;
	
	if (listSize % 2 == 0)
	{	
		position = (listSize / 2) - 1;
	}
	else
	{
		position = listSize / 2;
	}
	
	return convertIntToRank(sortedRanks[position]);
}

public void printMaintainability(MaintainabilityResult result)
{
	str volumeResult = convertRankToString(result.volume.rank);
	str complexityResult = convertRankToString(result.complexity.rank);
	str duplicationResult = convertRankToString(result.duplication.rank);
	str unitSizeResult = convertRankToString(result.unitSize.rank);
	str unitTestingResult = convertRankToString(result.unitTesting.rank);

	Rank analysabilityRank = medianRankOfPropertyRankings([result.volume, result.duplication, result.unitSize]);
	Rank changeabilityRank = medianRankOfPropertyRankings([result.complexity, result.duplication]);
	Rank stabilityRank = undefined();
	Rank testabilityRank = medianRankOfPropertyRankings([result.complexity, result.unitSize]);

	println("MAINTAINABILITY");
	println("--------------------------------------------------------------------------------------------------------------");
	println("\t\t| Volume\t| Complexity\t| Duplication\t| UnitSize\t| UnitTesting\t|| Result");
	println("--------------------------------------------------------------------------------------------------------------");
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
	println("--------------------------------------------------------------------------------------------------------------");
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

//Conversion from a int to an enumerated Rank
private Rank convertIntToRank(2) = plusPlus();
private Rank convertIntToRank(1) = plus();
private Rank convertIntToRank(0) = neutral();
private Rank convertIntToRank(int i) = minus() when i == -1;
private default Rank convertIntToRank(_) = minusMinus();


public list[bool] allTests() = [
								average1(),
								average2(),
								average3(),
								average4(),
								convertToTwo(),
								convertToOne(),
								convertToZero(),
								convertToMinusOne(),
								convertToMinusTwo()
								];

//Tests
//Test cases are extracted from figure 5 in "A Practical Model for Measuring Maintainability", http://dx.doi.org/10.1109/QUATIC.2007.8
test bool average1() = medianRankOfPropertyRankings([
														volume(plusPlus()), 
														duplication(minus()), 
														unitSize(minus()), 
														unitTesting(neutral())
													]) == minus();
														
test bool average2() = medianRankOfPropertyRankings([
														complexityPerUnit(minusMinus()), 
														duplication(minus())
													]) == minusMinus();
													
test bool average3() = medianRankOfPropertyRankings([unitTesting(neutral())]) == neutral();
test bool average4() = medianRankOfPropertyRankings([
														complexityPerUnit(minusMinus()),
														unitSize(minus()),
														unitTesting(neutral())
													]) == minus();



test bool convertToTwo() = convertRankToInt(plusPlus()) == 2;
test bool convertToOne() = convertRankToInt(plus()) == 1;
test bool convertToZero() = convertRankToInt(neutral()) == 0;
test bool convertToMinusOne() = convertRankToInt(minus()) == -1;
test bool convertToMinusTwo() = convertRankToInt(minusMinus()) == -2;

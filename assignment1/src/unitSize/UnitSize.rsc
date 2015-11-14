module unitSize::UnitSize

import Prelude;

import util::Math;

import model::MetricTypes;
import model::CodeUnitModel;
import model::CodeLineModel;
import IO;

//
// Holds the calculated metrics for Unit Size.
//
alias UnitSizeMetric = map[UnitSizeEvaluation eval,int percentage];

//
// Returns the Unit Size metric for a given project.
//
public UnitSizeMetric projectUnitSize(CodeUnitModel codeUnitModel)
{		
	map[UnitSizeEvaluation eval,int count] methodCount = (veryHigh(): 0, high(): 0, medium(): 0, low(): 0);
		
	for(method <- codeUnitModel) 
	{
		LOC numberOfLines = size(codeUnitModel[method].lines);

		methodCount[convertLOCEvaluation(numberOfLines)] += 1;
	}

	int nrOfMethods = (0 | it + methodCount[k] | k <- methodCount );

	return (
		veryHigh() : round((toReal(methodCount[veryHigh()]) / nrOfMethods * 100)),
		high()     : round((toReal(methodCount[high()]) / nrOfMethods * 100)),
		medium()   : round((toReal(methodCount[medium()]) / nrOfMethods * 100)),
		low()      : round((toReal(methodCount[low()]) / nrOfMethods * 100))
	);
}


public void printUnitSize(UnitSizeMetric results, Rank ranking)
{
	println("Unit Size");
	println("---------");
	println("Very High (\> 100): <results[veryHigh()]>%");
	println("High      (\> 50) : <results[high()]>%");
	println("Medium    (\> 10) : <results[medium()]>%");
	println("Low       (\> 0)  : <results[low()]>%");
	println();
	println("Ranking Unit Size: <ranking>");
}

public Rank convertUnitSizeMetricToRank(UnitSizeMetric metric) = plusPlus() 
	when metric[veryHigh()] == 0 && metric[high()] == 0 && metric[medium()] < 25;

public Rank convertUnitSizeMetricToRank(UnitSizeMetric metric) = plus() 
	when metric[veryHigh()] == 0 && metric[high()] < 5 && metric[medium()] < 30;

public Rank convertUnitSizeMetricToRank(UnitSizeMetric metric) = neutral() 
	when metric[veryHigh()] == 0 && metric[high()] < 10 && metric[medium()] < 40;

public Rank convertUnitSizeMetricToRank(UnitSizeMetric metric) = minus() 
	when metric[veryHigh()] < 5 && metric[high()] < 15 && metric[medium()] < 50;

public default Rank convertUnitSizeMetricToRank(UnitSizeMetric _) = minusMinus(); 


private UnitSizeEvaluation convertLOCEvaluation(LOC l) = veryHigh() when l > 100;
private UnitSizeEvaluation convertLOCEvaluation(LOC l) = high() when l > 50;
private UnitSizeEvaluation convertLOCEvaluation(LOC l) = medium() when l > 10;
private default UnitSizeEvaluation convertLOCEvaluation(LOC l) = low();



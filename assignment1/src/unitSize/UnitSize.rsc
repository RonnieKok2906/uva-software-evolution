module unitSize::UnitSize

import Prelude;
import util::Math;
import model::MetricTypes;
import model::CodeUnitModel;
import model::CodeLineModel;

data UnitSizeEvaluation = veryHigh() | high() | medium() | low();
map[UnitSizeEvaluation,int] thresholds = (veryHigh(): 100, high(): 50, medium(): 10, low(): 0); 

// Holds the calculated metric values for Unit Size.
alias UnitSizeMetric = map[UnitSizeEvaluation eval,int percentage];

//
// Returns the Unit Size metric for a given project.
//
public UnitSizeMetric projectUnitSize(CodeUnitModel codeUnitModel)
{		
	map[UnitSizeEvaluation eval,int count] methodLineCount = (veryHigh(): 0, high(): 0, medium(): 0, low(): 0);
		
	for(method <- codeUnitModel) 
	{
		LOC nrOfLinesInMethod = size(codeUnitModel[method].lines);

		methodLineCount[convertLOCEvaluation(nrOfLinesInMethod)] += nrOfLinesInMethod;
	}

	int totalNrOfLines = (0 | it + methodLineCount[k] | k <- methodLineCount );

	return (
		veryHigh() : round((toReal(methodLineCount[veryHigh()]) / totalNrOfLines * 100)),
		high()     : round((toReal(methodLineCount[high()]) / totalNrOfLines * 100)),
		medium()   : round((toReal(methodLineCount[medium()]) / totalNrOfLines * 100)),
		low()      : round((toReal(methodLineCount[low()]) / totalNrOfLines * 100))
	);
}

public void printUnitSize(UnitSizeMetric results, Rank ranking)
{
	println("Unit Size");
	println("---------");
	println("Very High (LoC \> <thresholds[veryHigh()]>): <results[veryHigh()]>%");
	println("High      (LoC \> <thresholds[high()]>) : <results[high()]>%");
	println("Medium    (LoC \> <thresholds[medium()]>) : <results[medium()]>%");
	println("Low       (LoC \> <thresholds[low()]>)  : <results[low()]>%");
	println();
<<<<<<< HEAD
	println("Unit Size ranking: <ranking>");
=======
	println("Unit Size ranking: <convertRankToString(ranking)>");
	println("--------------------------------------------");
	println();
>>>>>>> origin/master
	println();
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


private UnitSizeEvaluation convertLOCEvaluation(LOC l) = veryHigh() when l > thresholds[veryHigh()];
private UnitSizeEvaluation convertLOCEvaluation(LOC l) = high() when l > thresholds[high()];
private UnitSizeEvaluation convertLOCEvaluation(LOC l) = medium() when l > thresholds[medium()];
private default UnitSizeEvaluation convertLOCEvaluation(LOC l) = low();

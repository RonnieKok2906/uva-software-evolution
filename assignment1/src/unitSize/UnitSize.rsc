module unitSize::UnitSize

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import util::Math;
import model::MetricTypes;
import model::CodeUnitModel;
import model::CodeLineModel;

data UnitSizeEvaluation = veryHigh() | high() | medium() | low();

map[UnitSizeEvaluation,int] thresholds = (veryHigh(): 100, high(): 50, medium(): 10, low(): 0); 

//
// Holds the calculated metric values for Unit Size.
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
	println("Very High (LoC \> <thresholds[veryHigh()]>): <results[veryHigh()]>%");
	println("High      (LoC \> <thresholds[high()]>) : <results[high()]>%");
	println("Medium    (LoC \> <thresholds[medium()]>) : <results[medium()]>%");
	println("Low       (LoC \> <thresholds[low()]>)  : <results[low()]>%");
	println();
	println("Unit Size ranking: <ranking>");
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


test bool testUnitSizeWithoutCommentsAndEmptyLines()
{
	loc file = |project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	UnitSizeMetric result = projectUnitSize(codeUnitModel);
	
	UnitSizeMetric reference =  (low() : (10.0 / 77.0) * 100.0, medium() : (67.0 / 77.0) * 100.0, high() : (0.0 / 77.0) * 100.0, veryHigh() : (0.0/ 77.0) * 100.0);	
	
	return result == reference;
}

test bool testUnitSizeWithCommentsAndEmptyLines()
{
	loc file = |project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	UnitSizeMetric result = projectUnitSize(codeUnitModel);
	
	println(result);
	
	UnitSizeMetric reference =  (
								low() : round((10.0 / 77.0) * 100.0), 
								medium() : round((67.0 / 77.0) * 100.0), 
								high() : round((0.0 / 77.0) * 100.0), 
								veryHigh() : round((0.0/ 77.0) * 100.0)
								);	

	return result == reference;
}

public list[bool] allTests = [
								testUnitSizeWithoutCommentsAndEmptyLines(),
								testUnitSizeWithCommentsAndEmptyLines()
								];
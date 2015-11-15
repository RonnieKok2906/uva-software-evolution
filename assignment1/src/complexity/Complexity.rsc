module complexity::Complexity

import Prelude;

import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::MetricTypes;
import model::CodeLineModel;
import model::CodeUnitModel;

import Util;
import Conversion;

import complexity::CyclomaticComplexity;
import complexity::Conversion;

alias ComplexityMetric = map[ComplexityRiskEvaluation complexityRiskEvaluation, real percentage];

//Public Functions

public ComplexityMetric projectComplexity(CodeUnitModel model)
{
	set[Unit] units = range(model);

	ComplexityMetric complexityPie = complexityPie(units);
	
	return complexityPie;
}

public ComplexityMetric complexityPie(set[Unit] units)
{	
	map[ComplexityRiskEvaluation, list[Unit]] groupedUnitsPerRisk = groupedUnitsPerRisk(units);
	
	LOC totalLinesOfCode = size(units) > 0 ? linesOfCodeOfUnitList(units) : 1;
	
	LOC simpleLines = size(units) > 0 ? linesOfCodeOfUnitList(groupedUnitsPerRisk[simple()]) : 1;
	LOC moreComplexLines = size(units) > 0 ? linesOfCodeOfUnitList(groupedUnitsPerRisk[moreComplex()]) : 0;
	LOC complexLines = size(units) > 0 ? linesOfCodeOfUnitList(groupedUnitsPerRisk[complex()]) : 0;
	LOC untestableLines = size(units) > 0 ? linesOfCodeOfUnitList(groupedUnitsPerRisk[untestable()]) : 0;	
	
	ComplexityMetric result = (
								simple() : toReal(simpleLines) / toReal(totalLinesOfCode),
								moreComplex() : toReal(moreComplexLines) / toReal(totalLinesOfCode),
								complex() : toReal(complexLines) / toReal(totalLinesOfCode),
								untestable() : toReal(untestableLines) / toReal(totalLinesOfCode)
								);
	
	return result;
}

public void printComplexity(ComplexityMetric complexityPie)
{
	println("COMPLEXITY");
	
	printCCTable();
	
	printRankTable(complexityPie);
}
//Private Functions

private ComplexityRiskEvaluation complexityRiskForUnit(Unit unit)
{
	CC cc = cyclomaticComplexityForUnit(unit);
		
	return convertCCToComplexityRiskEvalutation(cc);
}

private CC cyclomaticComplexityForUnit(Unit unit)
{
	return cyclomaticComplexityForStatement(unit.statement);
}

private map[ComplexityRiskEvaluation, list[Unit]] groupedUnitsPerRisk(list[Unit] units) = groupedUnitsPerRisk(toSet(units));

private map[ComplexityRiskEvaluation, list[Unit]] groupedUnitsPerRisk(set[Unit] units)
{
	list[tuple [Unit, ComplexityRiskEvaluation]] complexityPerUnit = [];
	
	for (unit <- units)
	{
		complexityPerUnit += <unit, complexityRiskForUnit(unit)>;
	}

	list[Unit] simpleUnits = [];
	list[Unit] moreComplexUnits = [];
	list[Unit] complexUnits = [];
	list[Unit] untestableUnits = [];
	
	for (<u, c> <- complexityPerUnit)
	{
		switch (c)
		{
			case simple() : simpleUnits += u;
			case moreComplex() : moreComplexUnits += u;
			case complex() : complexUnits += u;
			case untestable() : untestableUnits += u;
			default : fail; 
		}
	}
	
	return (simple() : simpleUnits, 
			moreComplex() : moreComplexUnits, 
			complex() : complexUnits, 
			untestable() : untestableUnits
			);
}


module complexity::Rank

import Set;
import List;
import util::Math;

import MetricTypes;
import Conversion;
import unitSize::UnitSize;

import complexity::CyclomaticComplexity;
import complexity::Conversion;

import lang::java::jdt::m3::AST; 

//Public Functions

public Rank projectComplexity(set[Declaration] declarations)
{
	list[Unit] units = projectUnits(declarations);

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(units);
	
	return size(units) > 0 ? convertPieToRank(complexityPie) : neutral();
}


//TODO: refactor it to be simple and testable
public map[ComplexityRiskEvaluation, real] complexityPie(list[Unit] units)
{	
	map[ComplexityRiskEvaluation, list[Unit]] groupedUnitsPerRisk = groupedUnitsPerRisk(units);
	
	LOC totalLinesOfCode = size(units) > 0 ? linesOfCodeOfUnitList(units) : 1;
	
	LOC simpleLines = size(units) > 0 ? linesOfCodeOfUnitList(groupedUnitsPerRisk[simple()]) : 1;
	LOC moreComplexLines = size(units) > 0 ? linesOfCodeOfUnitList(groupedUnitsPerRisk[moreComplex()]) : 0;
	LOC complexLines = size(units) > 0 ? linesOfCodeOfUnitList(groupedUnitsPerRisk[complex()]) : 0;
	LOC untestableLines = size(units) > 0 ? linesOfCodeOfUnitList(groupedUnitsPerRisk[untestable()]) : 0;
	
	map[ComplexityRiskEvaluation, real] result = (
													simple() : toReal(simpleLines) / toReal(totalLinesOfCode),
													moreComplex() : toReal(moreComplexLines) / toReal(totalLinesOfCode),
													complex() : toReal(complexLines) / toReal(totalLinesOfCode),
													untestable() : toReal(untestableLines) / toReal(totalLinesOfCode)
													);
	
	return result;
}

public list[bool] allTests() = [];

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

private map[ComplexityRiskEvaluation, list[Unit]] groupedUnitsPerRisk(list[Unit] units)
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
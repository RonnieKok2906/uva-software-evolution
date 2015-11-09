module complexity::Ranking

import Set;
import List;
import Map;
import util::Math;

import lang::java::jdt::m3::Core;

import MetricTypes;
import CodeModel;
import Util;
import Conversion;
import unitSize::UnitSize;

import complexity::CyclomaticComplexity;
import complexity::Conversion;



//Public Functions

public Rank projectComplexity(CodeModel model)
{
	list[Unit] units = projectUnits(model);

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(units);
	
	return size(units) > 0 ? convertPieToRank(complexityPie) : neutral();
}

public map[ComplexityRiskEvaluation, real] complexityPie(CodeModel model)
{
	list[Unit] units = projectUnits(model);
	
	return complexityPie(units);
}

//Private Functions
private map[ComplexityRiskEvaluation, real] complexityPie(list[Unit] units)
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

private ComplexityRiskEvaluation complexityRiskForUnit(Unit unit)
{
	CC cc = cyclomaticComplexityForUnit(unit);
	
	return convertCCToComplexityRiskEvalutation(cc);
}

private CC cyclomaticComplexityForUnit(Unit unit)
{
	return cyclomaticComplexityForStatement(unit.statements);
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


//Tests
public list[bool] allTests() = [
								testNumberOfUnitsWithoutCommentsAndEmptyLines(),
								testNumberOfUnitsWithCommentsAndEmptyLines(),
								testComplexityPieWithoutCommentsAndEmptyLines(),
								testComplexityPieWithCommentsAndEmptyLines(),
								testSumComplexityPieWithoutCommentsAndEmptyLinesIsOne(),
								testSumComplexityPieWithCommentsAndEmptyLinesIsOne(),
								testRankWithoutCommentsAndEmptyLines(),
								testRankWithCommentsAndEmptyLines()
								];


test bool testNumberOfUnitsWithoutCommentsAndEmptyLines()
{
	M3 m3Model = createM3FromEclipseFile(|project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|);
	
	CodeModel codeModel = createCodeModel(m3Model);
	
	list[Unit] units = projectUnits(codeModel);

	return size(units) == 4;
}

test bool testNumberOfUnitsWithCommentsAndEmptyLines()
{	
	M3 m3Model = createM3FromEclipseFile(|project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|);
	
	CodeModel codeModel = createCodeModel(m3Model);
	
	list[Unit] units = projectUnits(codeModel);

	return size(units) == 4;
}

test bool testSumComplexityPieWithoutCommentsAndEmptyLinesIsOne()
{
	M3 m3Model = createM3FromEclipseFile(|project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|);
	
	CodeModel codeModel = createCodeModel(m3Model);
	
	list[Unit] units = projectUnits(codeModel);

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(units);
	
	real result = sum(range(complexityPie));
	
	return result > 0.9999 && result < 1.00001;
}

test bool testSumComplexityPieWithCommentsAndEmptyLinesIsOne()
{
	M3 m3Model = createM3FromEclipseFile(|project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|);
	
	CodeModel codeModel = createCodeModel(m3Model);
	
	list[Unit] units = projectUnits(codeModel);

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(units);
	
	real result = sum(range(complexityPie));
	
	return result > 0.9999 && result < 1.00001;
}

test bool testComplexityPieWithoutCommentsAndEmptyLines()
{
	M3 m3Model = createM3FromEclipseFile(|project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|);
	
	CodeModel codeModel = createCodeModel(m3Model);
	
	list[Unit] units = projectUnits(codeModel);

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(units);

	map[ComplexityRiskEvaluation, real] reference = (
													simple() : 6.0 / 69.0, 
													moreComplex() : 15.0 / 69.0, 
													complex() : 48.0 / 69.0, 
													untestable() : 0.0 / 69.0
													);
	
	return reference == complexityPie;
}

test bool testComplexityPieWithCommentsAndEmptyLines()
{
	M3 m3Model = createM3FromEclipseFile(|project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|);
	
	CodeModel codeModel = createCodeModel(m3Model);
	
	list[Unit] units = projectUnits(codeModel);

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(units);

	map[ComplexityRiskEvaluation, real] reference = (
													simple() : 6.0 / 69.0, 
													moreComplex() : 15.0 / 69.0, 
													complex() : 48.0 / 69.0, 
													untestable() : 0.0 / 69.0
													);
	
	return reference == complexityPie;
}

test bool testRankWithoutCommentsAndEmptyLines()
{	
	M3 m3Model = createM3FromEclipseFile(|project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|);
	
	CodeModel codeModel = createCodeModel(m3Model);
	
	Rank rank = projectComplexity(codeModel);
	
	return rank == minusMinus();
}

test bool testRankWithCommentsAndEmptyLines()
{	
	M3 m3Model = createM3FromEclipseFile(|project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|);
	
	CodeModel codeModel = createCodeModel(m3Model);
	
	Rank rank = projectComplexity(codeModel);
	
	return rank == minusMinus();
}
module complexity::ComplexityTests

import Prelude;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Util;
import Conversion;
import model::MetricTypes;
import model::CodeLineModel;
import model::CodeUnitModel;
import complexity::CyclomaticComplexity;
import complexity::Conversion;
import complexity::Complexity;

test bool testSumComplexityPieWithoutCommentsAndEmptyLinesIsOne()
{
	loc file = |project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(range(codeUnitModel));
	
	real result = sum(range(complexityPie));
	
	return result > 0.9999 && result < 1.00001;
}

test bool testSumComplexityPieWithCommentsAndEmptyLinesIsOne()
{
	loc file = |project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(range(codeUnitModel));
	
	real result = sum(range(complexityPie));
	
	return result > 0.9999 && result < 1.00001;
}

test bool testComplexityPieWithoutCommentsAndEmptyLines()
{
	loc file = |project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(range(codeUnitModel));

	map[ComplexityRiskEvaluation, real] reference = (
													simple() : 10.0 / 77.0, 
													moreComplex() : 17.0 / 77.0, 
													complex() : 50.0 / 77.0, 
													untestable() : 0.0 / 77.0
													);
	
	return reference == complexityPie;
}

test bool testComplexityPieWithCommentsAndEmptyLines()
{
	loc file = |project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(range(codeUnitModel));

	map[ComplexityRiskEvaluation, real] reference = (
													simple() : 10.0 / 77.0, 
													moreComplex() : 17.0 / 77.0, 
													complex() : 50.0 / 77.0, 
													untestable() : 0.0 / 77.0
													);
	
	return reference == complexityPie;
}

test bool testRankWithoutCommentsAndEmptyLines()
{	
	loc file = |project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});
	
	ComplexityMetric pie = projectComplexity(codeUnitModel);
	Rank rank = convertPieToRank(pie);
	
	return rank == minusMinus();
}

test bool testRankWithCommentsAndEmptyLines()
{	
	loc file = |project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});
	
	ComplexityMetric pie = projectComplexity(codeUnitModel);
	Rank rank = convertPieToRank(pie);
	
	return rank == minusMinus();
}

public list[bool] allTests() = [
								testComplexityPieWithoutCommentsAndEmptyLines(),
								testComplexityPieWithCommentsAndEmptyLines(),
								testSumComplexityPieWithoutCommentsAndEmptyLinesIsOne(),
								testSumComplexityPieWithCommentsAndEmptyLinesIsOne(),
								testRankWithoutCommentsAndEmptyLines(),
								testRankWithCommentsAndEmptyLines()
								];
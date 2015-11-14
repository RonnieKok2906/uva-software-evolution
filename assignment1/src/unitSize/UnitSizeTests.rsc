module unitSize::UnitSizeTests

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import model::CodeUnitModel;
import model::CodeLineModel;
import unitSize::UnitSize;


test bool testUnitSizeWithoutCommentsAndEmptyLines()
{
	// Arrange
	loc file = |project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	// Act
	UnitSizeMetric actual = projectUnitSize(codeUnitModel);
	
	// Assert
	UnitSizeMetric expected =  (
								low() : toInt(round((10.0 / 77.0) * 100.0)), 
								medium() : toInt(round((67.0 / 77.0) * 100.0)), 
								high() : toInt(round((0.0 / 77.0) * 100.0)), 
								veryHigh() : toInt(round((0.0/ 77.0) * 100.0))
								);	
	
	return actual == expected;
}

test bool testUnitSizeWithCommentsAndEmptyLines()
{
	// Arrange
	loc file = |project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	// Act
	UnitSizeMetric actual = projectUnitSize(codeUnitModel);
	
	// Assert
	UnitSizeMetric expected =  (
								low() : toInt(round((10.0 / 77.0) * 100.0)), 
								medium() : toInt(round((67.0 / 77.0) * 100.0)), 
								high() : toInt(round((0.0 / 77.0) * 100.0)), 
								veryHigh() : toInt(round((0.0/ 77.0) * 100.0))
								);	

	return actual == expected;
}

public list[bool] allTests() = [
								testUnitSizeWithoutCommentsAndEmptyLines(),
								testUnitSizeWithCommentsAndEmptyLines()
								];
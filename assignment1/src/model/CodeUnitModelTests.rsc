module model::CodeUnitModelTests

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import model::CodeLineModel;
import model::CodeUnitModel;

public list[bool] allTests() = [
								testNumberOfUnitsWithoutCommentsAndEmptyLines(),
								testNumberOfUnitsWithCommentsAndEmptyLines()
								];

test bool testNumberOfUnitsWithoutCommentsAndEmptyLines()
{
	// Arrange
	loc file = |project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	
	// Act
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	// Assert
	return size(codeUnitModel) == 4;
}

test bool testNumberOfUnitsWithCommentsAndEmptyLines()
{	
	// Arrange
	loc file = |project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	Declaration declaration = createAstFromFile(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	// Act
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, {declaration});

	// Assert
	return size(codeUnitModel) == 4;
}
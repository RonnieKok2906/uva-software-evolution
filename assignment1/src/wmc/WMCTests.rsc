module wmc::WMCTests

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import wmc::WMC;

test bool testThatProjectHasTwoClasses()
{
	loc file = |project://testSource|;
	M3 m3Model = createM3FromEclipseProject(file);
	declarations = createAstsFromEclipseProject(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, declarations);
	
	ClassModel classModel = createClassModel(m3Model, codeUnitModel);
	
	println(size(classModel));
	return size(classModel) == 2;
}

test bool testThatProjectHasEightMethods()
{
	loc file = |project://testSource|;
	M3 m3Model = createM3FromEclipseProject(file);
	declarations = createAstsFromEclipseProject(file, false);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	CodeUnitModel codeUnitModel = createCodeUnitModel(m3Model, codeLineModel, declarations);
	
	ClassModel classModel = createClassModel(m3Model, codeUnitModel);
	
	int numberOfMethods = (0 | it + size(classModel[c]) | c <- classModel);

	return numberOfMethods == 8;
}

test bool testThatClassesHaveEqualComplexity()
{
	loc file1 = |project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|;
	M3 m3Model1 = createM3FromEclipseFile(file1);
	Declaration declaration1 = createAstFromFile(file1, false);
	
	CodeLineModel codeLineModel1 = createCodeLineModel(m3Model1);
	CodeUnitModel codeUnitModel1 = createCodeUnitModel(m3Model1, codeLineModel1, {declaration1});
	
	ClassModel classModel1 = createClassModel(m3Model1, codeUnitModel1);
	
	
	loc file2 = |project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|;
	M3 m3Model2 = createM3FromEclipseFile(file2);
	Declaration declaration2 = createAstFromFile(file2, false);
	
	CodeLineModel codeLineModel2 = createCodeLineModel(m3Model2);
	CodeUnitModel codeUnitModel2 = createCodeUnitModel(m3Model2, codeLineModel2, {declaration2});
	
	ClassModel classModel2 = createClassModel(m3Model2, codeUnitModel2);
	
	bool sizesAreEqual = size(classModel1) == size(classModel2);
	
	WMC wmc1 = projectWMC(classModel1);
	WMC wmc2 = projectWMC(classModel2);
	
	return sizesAreEqual && range(wmc1) == range(wmc2);

}

public list[bool] allTests() = [
								testThatProjectHasTwoClasses(),
								testThatProjectHasEightMethods(),
								testThatClassesHaveEqualComplexity()
								];
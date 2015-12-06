module type2::Type2Tests

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::CloneModel;

import type2::CodeLineModel2;
import type2::Type2;
import type2::Config;

public list[bool] allTests() = [
								testThatClassOfOneLineHasNoCloneClasses(),
								testThatDifferentMethodNamesOrIgnored(),
								testThatDifferentMethodReturnTypeIsIngored(),
								testThatDifferentReturnExpressionIsRecognized(),
								testThatDifferentVariableNamesAreIgnored(),
								testThatDifferentNumericalLiteralsAreIgnored(),
								testThatWhiteSpaceIsIgnored()
								]; 
								
test bool testThatClassOfOneLineHasNoCloneClasses()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass1.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 1;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 0;
}

test bool testThatDifferentMethodNamesOrIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass2.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 3;
	
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

test bool testThatDifferentMethodReturnTypeIsIngored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass3.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 4;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

test bool testThatDifferentReturnExpressionIsRecognized()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass4.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 2;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 0;
}

test bool testThatDifferentVariableNamesAreIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass5.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 1;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);

	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

test bool testThatDifferentNumericalLiteralsAreIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass6.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 1;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

test bool testThatWhiteSpaceIsIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass7.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 3;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}


test bool testThatVariableTypeIsRespected()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass7.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 3;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

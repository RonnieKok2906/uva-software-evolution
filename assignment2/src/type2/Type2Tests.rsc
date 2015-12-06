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
								testThatDifferentMethodReturnTypeIsRespectedWithConfig(),
								testThatDifferentReturnExpressionIsRecognized(),
								testThatDifferentVariableNamesAreIgnored(),
								testThatDifferentNumericalLiteralsAreIgnored(),
								testThatWhiteSpaceIsIgnored(),
								testThatLiteralTypeIsRespectedWithConfig(),
								testThatLiteralTypeIsIgnored(),
								testThatDocumentationIsIgnored()
								]; 
	
//Test 1							
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

//Test 2
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

//Test 3a
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

//Test 3b
test bool testThatDifferentMethodReturnTypeIsRespectedWithConfig()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass3.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 4;
	config.respectMethodReturnType = true;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);

	//Assert
	return size(cloneModel) == 0;
}

//Test 4
test bool testThatDifferentReturnExpressionIsRecognized()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass4.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 3;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	println("cloneModel:<cloneModel>");
	//Assert
	return size(cloneModel) == 0;
}

//Test 5
test bool testThatDifferentVariableNamesAreIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass5.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 5;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);

	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}


//Test 6
test bool testThatDifferentNumericalLiteralsAreIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass6.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 5;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

//Test 7
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

//Test 8a
test bool testThatLiteralTypeIsRespectedWithConfig()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass8.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 3;
	config.respectLiteralType = true;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);

	//Assert
	return size(cloneModel) == 0;
}

//Test 8b
test bool testThatLiteralTypeIsIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass8.java|;
	
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

//Test 9
test bool testThatDocumentationIsIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass9.java|;
	
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

//Test 10a
test bool testThatDifferentVariableTypesAreIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass10.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 5;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

//Test 10b
test bool testThatDifferentVariableTypesAreRecognizedWithConfig()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass10.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel2 codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 5;
	config.respectVariableType = true;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	//Assert
	return size(cloneModel) == 0;
}

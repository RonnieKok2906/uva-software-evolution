module type1::Type1Tests

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::CloneModel;

import model::CodeLineModel;
import type1::Type1;
import type1::Config;


public list[bool] allTests() = [
								testThatWhiteSpaceIsIgnored(),
								testThatDocumentationIsIgnored(),
								testClonesInDifferenClasses()
								]; 

//Test 1
test bool testThatWhiteSpaceIsIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type1TestSource/TestClass1.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type1::Config::defaultConfiguration;
	config.minimumNumberOfLines = 6;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}


//Test 2
test bool testThatDocumentationIsIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type1TestSource/TestClass2.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type1::Config::defaultConfiguration;
	config.minimumNumberOfLines = 4;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}


//Test 2
test bool testClonesInDifferenClasses()
{
	//Arrange
	loc file = |project://testCloneSource/src/type1TestSource/TestClass3.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type1::Config::defaultConfiguration;
	config.minimumNumberOfLines = 6;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, config);
	
	//Assert
	return size(cloneModel) == 2 && size(cloneModel[1]) == 2 && size(cloneModel[2]) == 3;
}
module type3::Type3Tests

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::CloneModel;

import model::CodeLineModel;
import type3::Type3;
import type3::Config;

public list[bool] allTests() = [
								
								]; 
	
//Test 1							
test bool testThatClassOneLineRemovedIsIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type3TestSource/TestClass1.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = defaultConfiguration;
	config.numberOfLines = 3;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, config);
	
	println("print cloneModel:<size(cloneModel)>");
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}
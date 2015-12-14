module type2::Type2Tests

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::CloneModel;
import model::CodeLineModel;

import type2::Type2;
import type2::Config;

import normalization::Config;
import normalization::Normalization;


import typeUtil::TypeUtil;

public list[bool] allTests() = type1Tests() + type2Tests();
								
private list[bool] type1Tests() = [
								testThatWhiteSpaceIsIgnored(),
								testThatDocumentationIsIgnored()
								];

private list[bool] type2Tests() = [
									testThatClassOfOneLineHasNoCloneClasses(),
									testThatDifferentMethodNamesOrIgnored(),
									testThatDifferentMethodReturnTypeIsIngored(),
									testThatDifferentMethodReturnTypeIsRespectedWithConfig(),
									testThatDifferentReturnExpressionIsRecognized(),
									testThatDifferentVariableNamesAreIgnored(),
									testThatDifferentNumericalLiteralsAreIgnored(),
									testThatDifferentVariableTypesAreIgnored(),
									testThatDifferentVariableTypesAreRecognizedWithConfig(),
									testThatLiteralTypeIsRespectedWithConfig(),
									testThatLiteralTypeIsIgnored(),
									testThatPartOfACodeBlockIsRecognizedAsClone(),
									testThatAPartOfNestedCodeIsRecognizedAsClone()
									];

//Type 1
//Test 1
test bool testThatWhiteSpaceIsIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type1TestSource/TestClass1.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 3;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, normalization::Config::defaultConfiguration, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}


//Test 2
test bool testThatDocumentationIsIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type1TestSource/TestClass2.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 4;
	
	//Act
	CloneModel cloneModel = clonesInProject(codeLineModel, {declaration}, normalization::Config::defaultConfiguration, config);

	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}


//Type2	
//Test 1							
test bool testThatClassOfOneLineHasNoCloneClasses()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass1.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 1;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);
	
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
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 3;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);
	
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
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 4;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);
	
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
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 4;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	normalizationConfig.respectMethodReturnType = true;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);

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
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 3;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);

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
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 3;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);

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
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 5;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

//Test 7a
test bool testThatDifferentVariableTypesAreIgnored()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass7.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 5;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

//Test 7b
test bool testThatDifferentVariableTypesAreRecognizedWithConfig()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass7.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 5;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	normalizationConfig.respectVariableType = true;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);
	
	//Assert
	return size(cloneModel) == 0;
}


//Test 8a
test bool testThatLiteralTypeIsRespectedWithConfig()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass8.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 3;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	normalizationConfig.respectLiteralType = true;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);

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
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 3;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);

	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

//Test 9					
test bool testThatPartOfACodeBlockIsRecognizedAsClone()
{
	//Arrange
	loc file = |project://testCloneSource/src/type3TestSource/TestClass2.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 8;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}

//Test 10					
test bool testThatAPartOfNestedCodeIsRecognizedAsClone()
{
	//Arrange
	loc file = |project://testCloneSource/src/type2TestSource/TestClass9.java|;
	
	M3 m3Model = createM3FromEclipseFile(file);

	Declaration declaration = createAstsFromEclipseFile(file, true);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	Config config = type2::Config::defaultConfiguration;
	config.minimumNumberOfLines = 12;
	
	Config normalizationConfig = normalization::Config::defaultConfiguration;
	
	map[node, set[loc]] normalizedSubtrees = findAllRelevantNormalizedSubtrees({declaration}, normalizationConfig);
	map[int, list[list[CodeLine]]] subblocks = findSubblocks({declaration}, normalizationConfig, codeLineModel);
	
	//Act
	CloneModel cloneModel = clonesInProjectFromNormalizedSubtrees(normalizedSubtrees, subblocks, codeLineModel, config);
	
	//Assert
	return size(cloneModel) == 1 && size(cloneModel[1]) == 2;
}
module complexity::Complexity

import Set;
import List;
import util::Math;

import MetricTypes;
import Conversion;
import unitSize::UnitSize;
import complexity::ComplexityConversion;

import lang::java::jdt::m3::AST; 

//Public Functions

public Rank projectComplexity(set[Declaration] declarations)
{
	list[Unit] units = projectUnits(declarations);

	map[ComplexityRiskEvaluation, real] complexityPie = complexityPie(units);
	
	return size(units) > 0 ? convertPieToRank(complexityPie) : neutral();
}

//TODO: refactor it to be simple and testable
public map[ComplexityRiskEvaluation, real] complexityPie(list[Unit] units)
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

//Private Functions
private ComplexityRiskEvaluation complexityRiskForUnit(Unit unit)
{
	CC cc = cyclomaticComplexityForUnit(unit);
	
	return convertCCToComplexityRiskEvalutation(cc);
}

private CC cyclomaticComplexityForUnit(Unit unit)
{
	return cyclomaticComplexityForStatement(unit.statement);
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

public list[Statement] statementsFromDeclaration(Declaration declaration)
{
	list[Statement] statements = [];

	visit(declaration)
	{
		case /initializer(Statement impl): statements += impl;
		case /constructor(_, _, _, Statement impl): statements += impl;
		case /method(_, _, _, _, Statement impl): statements += impl;
	}
		
	return statements;
}

public CC cyclomaticComplexityForStatement(Statement statement) 
{
 	CC cc = 1;

 	visit(statement) 
 	{
 		case \do(Statement impl, _): cc += 1;
 	  	case \foreach(_, _, Statement impl): cc += 1;
 	  	case \for(_, _, _, Statement impl): cc += 1;
  		case \for(_, _, Statement impl): cc += 1;	
 	  	case \if(_, Statement elseImpl): cc += 1;
  		case \if(_, Statement thenImpl, Statement elseImpl): cc += 1;
  		case \switch(_, list[Statement] statements): cc += 1;
  		case \case(_): cc += 1;
  		case \catch(_, Statement impl): cc += 1;
  		case \while(_, Statement impl): cc += 1;
  		case \infix(_,"||",_): cc += 1;
  		case \infix(_,"&&",_): cc += 1;
  		case \conditional(_,_,_): cc += 1;
 	}

 	return cc;
}

test bool testSimpleMethod()
{
	str methodString = "public int test(){return 1;}";
	str classString = "class A{" + methodString + "}";
	
	Declaration declaration = createAstFromString(|file:///|, classString, true);
	
	Statement statement = head(statementsFromDeclaration(declaration));
	
	CC cc = cyclomaticComplexityForStatement(statement);
	
	return cc == 1;
}

test bool testMethodWithIfElseStatement()
{
	str ifStatement = "if(x == 1){ return = 0; }else{ return = 1;}";
	str methodString =  "public int test(){ int x = 1;" + ifStatement + "return 1; }";
	str classString = "class A{ " + methodString + " }";
	
	Declaration declaration = createAstFromString(|file:///|, classString, true);
	
	Statement statement = head(statementsFromDeclaration(declaration));
	
	CC cc = cyclomaticComplexityForStatement(statement);
	
	return cc == 2;
}

test bool testMethodWithNestedIfStatement()
{
	str ifStatement = "if(x == 1){ return = 0; }else{ return = 1;}";
	str nestedIfStatement = "if (x == 0){" + ifStatement + "}else{ return = 1;}";
	str methodString =  "public int test(){ int x = 1;" + nestedIfStatement + "return 1; }";
	str classString = "class A{ " + methodString + " }";
	
	Declaration declaration = createAstFromString(|file:///|, classString, true);
	
	Statement statement = head(statementsFromDeclaration(declaration));
	
	CC cc = cyclomaticComplexityForStatement(statement);
	
	return cc == 3;
}

test bool testIfStatementWithTwoInfixOperators()
{
	str ifStatement = "if(x == 1 && y == 2){ return = 0; }else{ return = 1;}";
	str methodString =  "public int test(){ bool m = (x == 1 || y == 3);" + ifStatement + "return 1; }";
	str classString = "class A{ " + methodString + " }";
	
	Declaration declaration = createAstFromString(|file:///|, classString, true);
	
	Statement statement = head(statementsFromDeclaration(declaration));
	
	CC cc = cyclomaticComplexityForStatement(statement);
	
	return cc == 4;
}

test bool testMethodWithConditional()
{
	str methodString = "public boolean test(){ return x = (x==1) ? true : false;}";
	str classString = "class A{" + methodString + "}";
	
	Declaration declaration = createAstFromString(|file:///|, classString, true);
	
	Statement statement = head(statementsFromDeclaration(declaration));
	
	CC cc = cyclomaticComplexityForStatement(statement);
	
	return cc == 2;
}

//I'm insecure if this is the right return value for cc
test bool testSwithStatement()
{
	str switchString = "switch(value){ case 1:{ return;}\ncase 2:{ return;}\ncase 3:{ return;}\ncase 4:{ return;}\ndefault:{ return;} }";
	str methodString = "public void test(){" + switchString + "}";
	str classString = "class A{" + methodString + "}";
	
	Declaration declaration = createAstFromString(|file:///|, classString, true);
	
	Statement statement = head(statementsFromDeclaration(declaration));
	
	CC cc = cyclomaticComplexityForStatement(statement);
	
	return cc == 6;
}

public list[bool] allTests() = [	testSimpleMethod(),
									testMethodWithIfElseStatement(),
									testMethodWithNestedIfStatement(),
									testIfStatementWithTwoInfixOperators(),
									testMethodWithConditional(),
									testSwithStatement()
								];
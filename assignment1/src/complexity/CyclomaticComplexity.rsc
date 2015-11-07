module complexity::CyclomaticComplexity

import List;

import lang::java::jdt::m3::AST; 

import Util;
import MetricTypes;

//Public functions
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
  		case \case(_): cc += 1;
  		case \defaultCase(): cc += 1;
  		case \catch(_, Statement impl): cc += 1;
  		case \while(_, Statement impl): cc += 1;
  		case \infix(_,"||",_): cc += 1;
  		case \infix(_,"&&",_): cc += 1;
  		case \conditional(_,_,_): cc += 1;
 	}

 	return cc;
}

public list[bool] allTests() = [	testSimpleMethod(),
									testMethodWithIfElseStatement(),
									testMethodWithNestedIfStatement(),
									testIfStatementWithTwoInfixOperators(),
									testMethodWithConditional(),
									testSwithStatement()
								];


//Tests
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
module complexity::CyclomaticComplexity

import Prelude;

import lang::java::jdt::m3::AST; 

import Util;
import model::MetricTypes;

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


//Function the retrieve the statement inside a method or constructor, only used for the tests
public Statement statementFromUnitDeclaration(Declaration declaration)
{
	visit(declaration)
	{
		case constructor(_, _, _, Statement impl): return impl;
		case method(_, _, _, _, Statement impl): return impl;
	}
		
	return [];
}


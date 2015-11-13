module model::CodeUnitModel

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::MetricTypes;
import model::CodeLineModel;

alias CodeUnitModel = map[loc method, Unit unit];

data Unit = unit(loc compilationUnit, CodeBlock codeBlock, list[Statement] statements);

public CodeUnitModel createCodeUnitModel(M3 m3Model, CodeLineModel codeLineModel)
{
	return ( m : unit(f, linesInMethod(f, codeLineModel), statementsInMethod(m3Model, m))  | <m,f> <- m3Model@declarations, m.scheme == "java+constructor" || m.scheme == "java+method" );
}

private CodeBlock linesInMethod(loc method, CodeLineModel codeLineModel)
{
	list[CodeLine] linesInFile = codeLineModel[method.top];
	
	return [ line | CodeLine line <- linesInFile, line.lineNumber >= method.begin.line && line.lineNumber <= method.end.line ];
}

private list[Statement] statementsInMethod(M3 m3Model, loc method)
{
	Declaration declaration = getMethodASTEclipse(method, model = m3Model);
	list[Statement] statements = statementsFromMethodDeclaration(declaration);
	
	return statements;
}

private list[Statement] statementsFromMethodDeclaration(Declaration declaration)
{
	list[Statement] statementsList = [];

	top-down-break visit (declaration)
	{
		case block(list[Statement] statements) : return statements;
	}
	
	return [];
}
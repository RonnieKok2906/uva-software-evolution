module model::CodeUnitModel

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::MetricTypes;
import model::CodeLineModel;

alias CodeUnitModel = map[loc method, Unit unit];

data Unit = unit(loc compilationUnit, list[CodeLine] lines, Statement statement);

public CodeUnitModel createCodeUnitModel(M3 m3Model, CodeLineModel codeLineModel, set[Declaration] declarations)
{
	CodeUnitModel codeUnitModel = ( f : unit(m, linesInMethod(f, codeLineModel), \return())  | <m,f> <- m3Model@declarations, m.scheme == "java+constructor" || m.scheme == "java+method" );
		
	return addStatementsToCodeUnitModel(declarations, codeUnitModel);
}

private list[CodeLine] linesInMethod(loc method, CodeLineModel codeLineModel)
{
	list[CodeLine] linesInFile = codeLineModel[method.top];
	
	return [ line | CodeLine line <- linesInFile, line.lineNumber >= method.begin.line && line.lineNumber <= method.end.line ];
}

public CodeUnitModel addStatementsToCodeUnitModel(set[Declaration] declarations, CodeUnitModel codeUnitModel)
{	
	for (d <- declarations)
	{
		visit(d)
		{
			case c:constructor(_, _, _, Statement impl) : codeUnitModel[c@src].statement = impl;
			case m:method(_, _, _, _, Statement impl) : codeUnitModel[m@src].statement = impl;
		}
	}
	
	return codeUnitModel;
}
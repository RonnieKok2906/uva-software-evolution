module Util

import lang::java::jdt::m3::AST;

public list[Statement] statementsFromDeclaration(Declaration declaration)
{
	list[Statement] statements = [];

	visit(declaration)
	{
		case initializer(Statement impl): statements += impl;
		case constructor(_, _, _, Statement impl): statements += impl;
		case method(_, _, _, _, Statement impl): statements += impl;
	}
		
	return statements;
}
module Util

import List;
import Set;

import lang::java::jdt::m3::AST;

import model::MetricTypes;
import model::CodeUnitModel;

//Accumulated Lines of Code of a list of MetricTypes::Unit.  
public LOC linesOfCodeOfUnitList([]) = 0;
public LOC linesOfCodeOfUnitList(list[Unit] units) = sum([size(u.codeBlock) | u <- units]);

//Accumulated Lines of Code of a set of MetricTypes::Unit.
public LOC linesOfCodeOfUnitList({}) = 0;
public LOC linesOfCodeOfUnitList(set[Unit] units) = sum([size(u.codeBlock) | u <- units]);

//Function the retrieve the statements inside a method or constructor
public list[Statement] statementsFromUnitDeclaration(Declaration declaration)
{
	list[Statement] statements = [];

	visit(declaration)
	{
		//MEMO:should the initializer really be here?
		case initializer(Statement impl): statements += impl;
		case constructor(_, _, _, Statement impl): statements += impl;
		case method(_, _, _, _, Statement impl): statements += impl;
	}
		
	return statements;
}
module unitSize::UnitSize

import List;
import String;
import IO;

import util::Math;

import lang::java::jdt::m3::AST;

import MetricTypes;

//TODO: implement
public Rank projectUnitSize(set[Declaration] declarations)
{
	 return neutral();
}

public list[Unit] projectUnits(set[Declaration] declarations)
{	
	list[Unit] units = [];

	for (d <- declarations)
	{
		visit(d)
		{
			case constructor(_, _, _, Statement impl): units += unit(d@src, impl@src, impl, numberOfLines(readFile(impl@src)));
			case method(_, _, _, _, Statement impl): units += unit(d@src, impl@src, impl, numberOfLines(readFile(impl@src)));
		}
	}
	
	return units;
}

private list[Statement] statementsFromDeclaration(Declaration declaration)
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

private list[Unit] projectUnitsSortedOnSize(loc project)
{
	list[Unit] units = projectUnits(project);
	
	list[Unit] sortedUnits = sort(units, bool (Unit a, Unit b) { return (a.linesOfCode > b.linesOfCode); });
	
	return sortedUnits;
}

private real averageUnitSize(loc project)
{
	set[Unit] units = projectUnits(project);
	
	LOC summedLinesOfCode = linesOfCodeOfUnitList(units);
	
	return toReal(summedLinesOfCode) / toReal(size(units));	
}

public LOC linesOfCodeOfUnitList([]) = 0;
public LOC linesOfCodeOfUnitList(list[Unit] units) = sum([u.linesOfCode | u <- units]);

public LOC linesOfCodeOfUnitList({}) = 0;
public LOC linesOfCodeOfUnitList(set[Unit] units) = sum([u.linesOfCode | u <- units]);

//TODO: Create tests; Do comments count? Do empty lines count?
private LOC numberOfLines(CodeFragment codeFragment) = size(split("\n", codeFragment));
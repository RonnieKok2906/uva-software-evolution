module unitSize::UnitSize

import Set;
import List;
import String;
import IO;

import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import MetricTypes;

//TODO: implement
public Rank projectUnitSize(loc project)
{
	 return neutral();
}

public set[Unit] projectUnits(loc project)
{
	M3 projectModel = createM3FromEclipseProject(project);
	
	set[loc] methods = methods(projectModel);
	
	set[Unit] result = {};
	
	for (m <- methods)
	{
		CodeFragment code = readFile(m);
		result = result + unit(m, code, numberOfLines(code));
	}

	return result;
}

public list[Unit] projectUnitsSortedOnSize(loc project)
{
	set[Unit] units = projectUnits(project);
	
	list[Unit] sortedUnits = sort(units, bool (Unit a, Unit b) { return (a.linesOfCode > b.linesOfCode); });
	
	return sortedUnits;
}

public real averageUnitSize(loc project)
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


//TODO: Create test;
private LOC numberOfLines(Unit unit) = numberOfLines(unit.codeFrogment);

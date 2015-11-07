module unitSize::UnitSize

import List;
import String;
import IO;

import util::Math;

import lang::java::jdt::m3::AST;

import MetricTypes;
import Util;

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
			case constructor(_, _, _, Statement impl) : units += unit(d@src, impl@src, methodStatements(impl), numberOfLines(codeFragmentsFromMethod(impl)));
			case method(_, _, _, _, Statement impl) : units += unit(d@src, impl@src, methodStatements(impl), numberOfLines(codeFragmentsFromMethod(impl)));
		}
	}
	
	return units;
}

private list[Statement] methodStatements(Statement impl)
{
	top-down-break visit(impl)
	{
		case block(list[Statement] statements) : return statements; 
		//MEMO:What if a method isn't declared correctly?
		default: return;
	}
}

private list[CodeFragment] codeFragmentsFromMethod(Statement statement)
{
	top-down-break visit(statement)
	{
		case block(list[Statement] statements) : return [readFile(s@src) | s <- statements]; 
		//MEMO:What if a method isn't declared correctly?
		default: return[];
	}
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

//TODO: Create tests; Do comments count? Do empty lines count?
private LOC numberOfLines(list[CodeFragment] codeFragments)
{
	list[int] listWithNumberOfLines = [size(split("\n", cf)) | cf <- codeFragments];
	
	return size(listWithNumberOfLines) == 0 ? 0 : sum(listWithNumberOfLines);
}
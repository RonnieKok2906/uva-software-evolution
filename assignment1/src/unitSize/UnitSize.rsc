module unitSize::UnitSize

import List;
import String;
import IO;

import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import MetricTypes;
import Util;

import CodeModel;

data UnitSize = unitSize(loc method, loc file, LOC linesOfCode, UnitSizeEvaluation evaluation); 


public Rank projectUnitSize(CodeModel codeModel, M3 m3Model)
{
	list[tuple[loc method, loc file]] methods = 
		[ <m,f> | <m,f> <- m3Model@declarations, m.scheme == "java+constructor" || m.scheme == "java+method" ];
		
	list[UnitSize] unitSizes = [];
		
	for(<method,file> <- methods) 
	{
		LOC numberOfLines = size(linesInMethod(file, codeModel));

		unitSizes += unitSize(method, file, numberOfLines, convertLOCEvaluation(numberOfLines));
	}

	int nrOfMethods = size(methods);
	int nrOfVeryHigh = size([m | m <-  unitSizes, m.evaluation == veryHigh() ]);
	int nrOfHigh = size([m | m <-  unitSizes, m.evaluation == high() ]);
	int nrOfMedium = size([m | m <-  unitSizes, m.evaluation == medium() ]);
	int nrOfLow = size([m | m <-  unitSizes, m.evaluation == low() ]);

	println("Total number of methods: <nrOfMethods>");

	println("Very High: <nrOfVeryHigh> (<nrOfVeryHigh / nrOfMethods * 100>%)");
	println("High: <nrOfHigh> (<nrOfHigh / nrOfMethods * 100>%)");
	println("Medium: <nrOfMedium> (<nrOfMedium / nrOfMethods * 100>%)");
	println("Low: <nrOfLow> (<nrOfLow / nrOfMethods * 100>%)");


	return neutral();
}

public list[CodeLine] linesInMethod(loc method, CodeModel codeModel)
{
	list[CodeLine] linesInFile = codeModel[method.top];
	
	return [ line | CodeLine line <- linesInFile, line.lineNumber >= method.begin.line && line.lineNumber <= method.end.line ];
}



public UnitSizeEvaluation convertLOCEvaluation(LOC l) = veryHigh() when l > 100;
public UnitSizeEvaluation convertLOCEvaluation(LOC l) = high() when l > 50;
public UnitSizeEvaluation convertLOCEvaluation(LOC l) = medium() when l > 10;
public default UnitSizeEvaluation convertLOCEvaluation(LOC l) = low();





public list[Unit]projectUnits(M3 model)
{
//MEMO:To be implemented? or the next one?
	return [];
}

public list[Unit] projectUnits(CodeModel model)
{
//MEMO:To be implemented? or the previous one? Ton:I think this one.
	return [];
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
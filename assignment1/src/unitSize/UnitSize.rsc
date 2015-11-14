module unitSize::UnitSize

import Prelude;

import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Util;

import model::MetricTypes;
import model::CodeUnitModel;
import model::CodeLineModel;

data UnitSize = unitSize(loc method, loc file, LOC linesOfCode, UnitSizeEvaluation evaluation); 

public Rank projectUnitSize(CodeUnitModel codeUnitModel)
{		
	list[UnitSize] unitSizes = [];
		
	for(method <- codeUnitModel) 
	{
		LOC numberOfLines = size(codeUnitModel[method].lines);

		unitSizes += unitSize(method, codeUnitModel[method].compilationUnit, numberOfLines, convertLOCEvaluation(numberOfLines));
	}

	int nrOfMethods = size(codeUnitModel);
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

public UnitSizeEvaluation convertLOCEvaluation(LOC l) = veryHigh() when l > 100;
public UnitSizeEvaluation convertLOCEvaluation(LOC l) = high() when l > 50;
public UnitSizeEvaluation convertLOCEvaluation(LOC l) = medium() when l > 10;
public default UnitSizeEvaluation convertLOCEvaluation(LOC l) = low();


private list[Unit] projectUnitsSortedOnSize(loc project)
{
	list[Unit] units = projectUnits(project);
	
	list[Unit] sortedUnits = sort(units, bool (Unit a, Unit b) { return (a.linesOfCode > b.linesOfCode); });
	
	return sortedUnits;
}
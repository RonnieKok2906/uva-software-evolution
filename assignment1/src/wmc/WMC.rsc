module wmc::WMC

import Prelude;
import List;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import model::MetricTypes;
import model::CodeLineModel;
import model::CodeUnitModel;
import complexity::CyclomaticComplexity;

data Class = class(loc name, loc location);
alias WMC = map[Class, CC];

//This metric comes from the article:
//http://www.computer.org.proxy.uba.uva.nl:2048/csdl/trans/ts/1994/06/e0476.pdf

public list[Class] projectClasses(M3 m3Model)
{
	return [class(d[0], d[1]) | d <- m3Model@declarations, d[0].scheme == "java+class"];
}

alias ClassModel = map[Class, list[Unit]];

public ClassModel creaeteClassModel(M3 m3Model, CodeUnitModel codeUnitModel)
{
	list[Class] classes = projectClasses(m3Model);
}


public ClassModel createClassModel(M3 m3Model, CodeUnitModel codeUnitModel)
{
	list[Class] classes = projectClasses(m3Model);
	
	ClassModel classModel = ();	
	
	for (c <-classes)
	{
		classModel[c] = [];
	}
	
	for (c <- classes)
	{
		for (u <- codeUnitModel)
		{
			if (u.path == c.location.path && u.begin.line >= c.location.begin.line && u.end.line <= c.location.end.line)
			{
				classModel[c] += [codeUnitModel[u]];
			}
		}
	}
	
	return classModel;
}

public WMC projectWMC(ClassModel classModel)
{	
	WMC wmc = (c : (0 | it + cyclomaticComplexityForStatement(m.statement) | m <- classModel[c]) | c <- classModel);
	
	return wmc;
}

public WMC topMostComplexClasses(WMC wmc)
{	
	list[int] sortedRange = reverse(sort(range(wmc)));
	int max = 5;
	
	if (size(wmc) < 5)
	{
		max = size(wmc);
	}

	return rangeR(wmc, toSet(sortedRange[0..max]));
}

public void printTopWMC(WMC wmc)
{
	println();
	println("WEIGHTED METHODS PER CLASS");
	println("--------------------------------------------");
	
	WMC top = topMostComplexClasses(wmc);
	
	println("Top <size(top)> of most complex classes (out of <size(wmc)>):");
	
	for (c <- top)
	{
		println("Summed Cyclomatic Complexity:<top[c]>, <c.location>");
	}	
	println("--------------------------------------------");
}
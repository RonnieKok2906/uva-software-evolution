module wmc::WMC

import Prelude;

import model::MetricTypes;

import model::CodeUnitModel;
import model::ClassModel;

import complexity::CyclomaticComplexity;

alias WMC = map[Class, CC];

//This metric comes from the article:
//http://www.computer.org.proxy.uba.uva.nl:2048/csdl/trans/ts/1994/06/e0476.pdf

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
	println("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
	
	WMC top = topMostComplexClasses(wmc);
	
	println("Top <size(top)> of most complex classes (out of <size(wmc)>):");
	println("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
	
	for (c <- top)
	{
		println("Summed Cyclomatic Complexity:<top[c]>, <c.location>");
	}	
	println("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
	println();
}
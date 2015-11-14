module model::ClassModel

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import model::MetricTypes;

import model::CodeUnitModel;

data Class = class(loc name, loc location);
alias ClassModel = map[Class, list[Unit]];


//Public Functions

public ClassModel createClassModel(M3 m3Model, CodeUnitModel codeUnitModel)
{
	list[Class] classes = projectClasses(m3Model);
	
	ClassModel classModel = initializeClassModel(classes);
	
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

//Private Functions

private list[Class] projectClasses(M3 m3Model)
{
	return [class(d[0], d[1]) | d <- m3Model@declarations, d[0].scheme == "java+class"];
}

private ClassModel initializeClassModel(list[Class] classes)
{
	ClassModel classModel = ();

	for (c <-classes)
	{
		classModel[c] = [];
	}
	
	return classModel;
}
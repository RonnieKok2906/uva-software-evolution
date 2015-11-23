module model::PackageModel

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import model::CodeLineModel;

data Package = package(loc file, set[Package] subPackages, set[loc] compilationUnits, LOC linesOfCode);

alias PackageModel = set[Package];

public PackageModel createPackageModel(M3 m3Model, CodeLineModel codeLineModel)
{
	set[loc] allPackageLocations = getPackages(m3Model);
	
	map[loc package, set[loc] files] filesPerPackage = initializeCompilationUnitPackageMap(allPackageLocations);
	
	packageCompilationUnitRelation = {<from, to> | <from, to> <- m3Model@containment, from.scheme == "java+package" && to.scheme == "java+compilationUnit"};
	
	map[loc,loc] schemeToFileOfCompilationUnit = (from:to | <from, to> <- m3Model@declarations, from.scheme == "java+compilationUnit");
	
	for (cu <- packageCompilationUnitRelation)
	{
		filesPerPackage[cu[0]] += schemeToFileOfCompilationUnit[cu[1]];
	}
	
	map[loc, Package] packageObjects = (p:package(p, {}, filesPerPackage[p], 6) | p <- allPackageLocations);
	
	rel[loc, loc] childPackageRelations = getChildPackageRelation(m3Model);
	set[loc] childPackages = getChildPackages(m3Model);
	set[loc] rootPackages = getRootPackages(m3Model);
	
	for (cp <- childPackageRelations)
	{
		packageObjects[cp[0]].subPackages += {packageObjects[cp[1]]};
	}
	
	set[Package] result = {packageObjects[p] | p <- rootPackages};

	return addLinesOfCode(result, codeLineModel);
}

private map[loc package, set[loc] files] initializeCompilationUnitPackageMap(set[loc] packages)
{
	map[loc package, set[loc] files] filesPerPackage = ();

	for (p <- packages)
	{
		filesPerPackage[p] = {};
	}
	
	return filesPerPackage;
}

public set[Package] addLinesOfCode(set[Package] packages, CodeLineModel codeLineModel)
{
	set[Package] returnList = {};
	
	println("addLines");
	for (p <- packages)
	{
		LOC linesOfCode = numberOfLinesInPackage(p, codeLineModel);
		Package newPackage = package(p.file, addLinesOfCode(p.subPackages, codeLineModel), p.compilationUnits, linesOfCode);
		
		returnList += newPackage;
	}
	
	return returnList;
}

public LOC numberOfLinesInPackage(Package package, CodeLineModel codeLineModel)
{
	package.linesOfCode = 0;

	LOC numberOfLinesInCompilationUnits = numberOfLinesInCompilationUnits(package.compilationUnits, codeLineModel);

	if (size(package.subPackages) > 0)
	{
		package.linesOfCode = (0 | it + numberOfLinesInPackage(i, codeLineModel) | i <- package.subPackages);
	}

	package.linesOfCode += numberOfLinesInCompilationUnits;
	
	return package.linesOfCode;
}

public LOC numberOfLinesInCompilationUnits(set[loc] compilationUnits, CodeLineModel codeLineModel)
{
	if (size(compilationUnits) > 0)
	{
		return (0 | it + size(codeLineModel[c.top]) | c <- compilationUnits);
	}
	
	return 0;
}

public rel[loc,loc] getChildPackageRelation(M3 m3Model)
{
	return {<name, file> | <name, file> <- m3Model@containment, name.scheme == "java+package" && file.scheme == "java+package"};
}

public set[loc] getChildPackages(M3 m3Model)
{
	return {f | <n,f> <- getChildPackageRelation(m3Model)};
}

public set[loc] getRootPackages(M3 m3Model)
{
	return {p | p <- getPackages(m3Model), !(p in getChildPackages(m3Model))};
}

public set[loc] getPackages(M3 m3Model)
{
	return {name | <name, file> <- m3Model@containment, name.scheme == "java+package"};
}

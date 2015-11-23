module model::PackageModel

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

data Package = package(loc file, set[Package] subPackages, set[loc compilationUnit] compilationUnits);

alias PackageModel = list[Package];

public PackageModel createPackageModel(M3 m3Model)
{
	set[loc] allPackageLocations = getPackages(m3Model);
	
	map[loc package, set[loc] files] filesPerPackage = initializeCompilationUnitPackageMap(allPackageLocations);
	
	packageCompilationUnitRelation = {<from, to> | <from, to> <- m3Model@containment, from.scheme == "java+package" && to.scheme == "java+compilationUnit"};
	
	for (cu <- packageCompilationUnitRelation)
	{
		filesPerPackage[cu[0]] += cu[1];
	}
	
	map[loc, Package] packageObjects = (p:package(p, {}, filesPerPackage[p]) | p <- allPackageLocations);
	
	rel[loc, loc] childPackageRelations = getChildPackageRelation(m3Model);
	set[loc] childPackages = getChildPackages(m3Model);
	set[loc] rootPackages = getRootPackages(m3Model);
	
	for (cp <- childPackageRelations)
	{
		packageObjects[cp[0]].subPackages += {packageObjects[cp[1]]};
	}
	
	list[Package] result = [packageObjects[p] | p <- rootPackages];

	return result;
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

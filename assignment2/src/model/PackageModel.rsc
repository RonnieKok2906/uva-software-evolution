module model::PackageModel

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

data Package = package(loc file, set[Package] subPackages, set[loc compilationUnit] compilationUnits);

alias PackageModel = list[Package];

public PackageModel createPackageModel(M3 m3Model)
{
	map[loc package, set[loc] files] filesPerPackage = ();
	
	list[loc] allPackageLocations = [name | <name, file> <- m3Model@containment, name.scheme == "java+package"];
	
	for (p <- allPackageLocations)
	{
		filesPerPackage[p] = {};
	}
	
	packageCompilationUnitRelation = {<from, to> | <from, to> <- m3Model@containment, from.scheme == "java+package" && to.scheme == "java+compilationUnit"};
	
	for (cu <- packageCompilationUnitRelation)
	{
		filesPerPackage[cu[0]] += cu[1];
	}
	
	map[loc, Package] packageObjects = (p:package(p, {}, filesPerPackage[p]) | p <- allPackageLocations);
	
	list[tuple[loc, loc]] childPackageRelations = [<name, file> | <name, file> <- m3Model@containment, name.scheme == "java+package" && file.scheme == "java+package"];
	list[loc] childPackages = [f | <n,f> <- childPackageRelations];
	list[loc] rootPackages = [p | p <- allPackageLocations, !(p in childPackages)];
	
	for (cp <- childPackageRelations)
	{
		packageObjects[cp[0]].subPackages += {packageObjects[cp[1]]};
	}
	
	list[Package] result = [packageObjects[p] | p <- rootPackages];

	return result;
}


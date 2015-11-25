module model::PackageModel

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import model::CodeLineModel;

data CompilationUnit = compilationUnit(loc file, str name, list[CodeLine] lines);

data Package = package(loc file, str name, set[Package] subPackages, set[CompilationUnit] compilationUnits);

alias PackageModel = set[Package];

public str getPackageNameFromScheme(loc file)
{
	return last(split("/", file.path));
}

public str getClassNameFromLocation(loc file)
{
	str nameWithExtension = last(split("/", file.path));

	str result = head(split(".java", nameWithExtension));
	
	return result;
}

public PackageModel createPackageModel(M3 m3Model, CodeLineModel codeLineModel)
{
	set[loc] allPackageLocations = getPackages(m3Model);
	
	map[loc package, set[CompilationUnit] compilationUnits] filesPerPackage = initializeCompilationUnitPackageMap(allPackageLocations);
	
	packageCompilationUnitRelation = {<from, to> | <from, to> <- m3Model@containment, from.scheme == "java+package" && to.scheme == "java+compilationUnit"};
	
	map[loc,CompilationUnit] schemeToCompilationUnit = (from:compilationUnit(to, getClassNameFromLocation(to.top), codeLineModel[to.top]) | <from, to> <- m3Model@declarations, from.scheme == "java+compilationUnit");
	
	for (cu <- packageCompilationUnitRelation)
	{
		filesPerPackage[cu[0]] += {schemeToCompilationUnit[cu[1]]};
	}
	
	map[loc, Package] packageObjects = (p:package(p, getPackageNameFromScheme(p), {}, filesPerPackage[p]) | p <- allPackageLocations);
	
	rel[loc, loc] childPackageRelations = getChildPackageRelation(m3Model);
	set[loc] childPackages = getChildPackages(m3Model);
	set[loc] rootPackages = getRootPackages(m3Model);
	
	for (cp <- childPackageRelations)
	{
		packageObjects[cp[0]].subPackages += {packageObjects[cp[1]]};
	}
	
	set[Package] result = {packageObjects[p] | p <- rootPackages};

	return result;
}

private map[loc package, set[CompilationUnit] compilationUnits] initializeCompilationUnitPackageMap(set[loc] packages)
{
	map[loc package, set[CompilationUnit] compilationUnits] filesPerPackage = ();

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

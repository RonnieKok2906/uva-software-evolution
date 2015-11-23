module model::PackageModel

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

data Package = package(list[Package] subPackages, list[loc compilationUnit] compilationUnits);

alias PackageModel = list[Package];

PackageModel createPackageModel(M3 m3Model)
{
	return package([],[]);
}
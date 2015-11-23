module CloneTypes

import CodeLineModel;

alias CodeFragment = list[CodeLine];

alias CloneClass = list[CodeFragment];

data Package = package(list[Package] subPackages, list[loc compilationUnit] compilationUnits);

alias PackageModel = list[Package];


str formatToJSON(list[CloneClass] cloneClasses, CodeLineModel codeLineModel, PackageModel packageModel)
{
	return "undefined";
}

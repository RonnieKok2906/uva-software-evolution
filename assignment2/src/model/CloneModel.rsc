module model::CloneModel

import Prelude;

import model::CodeLineModel;
import model::PackageModel;

alias CloneFragment = tuple[int cloneClassIdentifier, int cloneIdentifier, list[CodeLine] lines];
alias CloneClass = list[CloneFragment];

alias CloneModel = map[int identifier, CloneClass cloneClass];

public map[loc compilationUnit, list[CloneFragment] cloneFragments] clonesMappedOnCompilationUnit(set[loc] compilationUnits, CloneModel cloneModel)
{
	map[loc compilationUnit, list[CloneFragment] cloneFragments] returnMap = (c:[] | c <- compilationUnits);

	for (k <- cloneModel)
	{
		for (c <- cloneModel[k])
		{
			if (size(c.lines) == 0)
			{
				println("no lines:<cloneModel[k]>");
			}
		
			returnMap[c.lines[0].fileName] += c;		
		}
	}
	
	return returnMap;
}

public list[loc] getFilesFromCloneModel(CloneModel cloneModel) 
{
	list[loc] files = [];
	
	for(k <- cloneModel) 
	{
		for(clone <- cloneModel[k]) 
		{
			file = clone[2][0].fileName;
			
			if(file notin files) 
			{
				files += file;
			}
		}
	}
	return files;
}
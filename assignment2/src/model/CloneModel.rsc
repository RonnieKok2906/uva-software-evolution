module model::CloneModel

import Prelude;

import model::CodeLineModel;
import model::PackageModel;

alias CloneFragment = tuple[int cloneClassIdentifier, int cloneIdentifier, list[CodeLine] lines];
data CloneType = type1() | type2() | type3() | type4();

// Proposed replacement for CloneFragment.
data Clone = clone(int cloneId, int classId, loc filename, list[CodeLine] lines); 
 
alias CloneClass = list[CloneFragment];
alias CloneModel = map[int classId, CloneClass cloneClass];

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
			file = clone.lines[0].fileName;
			
			if(file notin files) 
			{
				files += file;
			}
		}
	}
	return files;
}

public list[CloneFragment] getClonesFromFile(CloneModel cloneModel, loc filename) 
{
	list[CloneFragment] clones = [];
	
	for(k <- cloneModel) 
	{
		for(clone <- cloneModel[k]) 
		{
			loc file = clone.lines[0].fileName;
			
			if(file == filename) 
			{
				clones += clone;
			}
		}		
	}	
	return clones;
} 

public list[int] cloneRange(CloneFragment clone) 
{
	return [ codeLine.orderNumber | codeLine <- clone.lines ];
}

//
// Determines whether to ranges overlap each other.
//
public bool rangeOverlaps(list[int] range1, list[int] range2) 
{
	return false;
}


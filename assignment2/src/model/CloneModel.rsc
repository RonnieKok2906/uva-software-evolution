module model::CloneModel

import Prelude;

import model::CodeLineModel;
import model::PackageModel;

data Clone = clone(int cloneClassIdentifier, int cloneId, loc filename, list[CodeLine] lines); 
data CloneType = type1() | type2() | type3() | type4();

alias CloneClass = list[Clone];
alias CloneModel = map[int classId, CloneClass cloneClass];

//These types could be refactored to this.
//data CloneClass = cloneClass(int classId, list[Clone]);
//alias CloneModel = list[CloneClass];

public map[loc compilationUnit, list[Clone] clonees] clonesMappedOnCompilationUnit(set[loc] compilationUnits, CloneModel cloneModel)
{
	map[loc compilationUnit, list[Clone] cloneFragments] returnMap = (c:[] | c <- compilationUnits);

	for (k <- cloneModel)
	{
		for (c <- cloneModel[k])
		{
			if (size(c.lines) == 0)
			{
				println("no lines:<cloneModel[k]>");
			}
		
			returnMap[c.filename] += c;		
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
			file = clone.filename;
			
			if(file notin files) 
			{
				files += file;
			}
		}
	}
	return files;
}

public list[Clone] getClonesFromFile(CloneModel cloneModel, loc filename) 
{
	list[Clone] clones = [];

	for(k <- cloneModel) 
	{
		for(clone <- cloneModel[k]) 
		{
			loc file = clone.filename;
			
			if(file == filename) 
			{
				clones += clone;
			}
		}		
	}	
	return clones;
} 

//
// Tries to make the largset possible clones in a clone model.
//
public CloneModel normalizeCloneModel(CloneModel model) 
{
	list[loc] files = getFilesFromCloneModel(model);
	
	for(file <- files) 
	{
		// List of clones from the same file.
		list[Clone] clones = getClonesFromFile(model, file);
		
		// Maak de grootste mogelijke clones.
		list[Clone] largestPossibleClones = consolidateClones(clones);
		
		// Maak alle mogelijke subclones.
		
		
		 
	}
	
	
	// Vergelijk alle subclones met elkaar. Filter weg wat geen clone is.
	
	// 
}

public list[Clone] consolidateClones(list[Clone] clones)
{
	Clone first = head(clones);

	// Select all clones that overlaps with the first
	clonesWithOverlap = [ c | c <- clones, clonesAreAdjacentOrOverlaps(first, c) ];
	remaining = [ c | c <- clones, !clonesAreAdjacentOrOverlaps(first, c) ];

	// Merge the clones with overlap
	Clone mergedClone = mergeClones(clonesWithOverlap); 

	return mergedClone + consolidateClones(remaining);
}



public bool clonesAreAdjacentOrOverlaps(Clone clone1, Clone clone2) 
{
	list[int] range1 = cloneRange(clone1);
	list[int] range2 = cloneRange(clone2);
	
	return rangesAreAdjacentOrOverlaps(range1, range2);
}

//
// Assuming all given clone fragments are from the same file and are adjacent or overlapping each other...
// ... merge all clone fragments into one large fragment.
//
public Clone mergeClones(list[Clone] clones)
{
	assert !isEmpty(clones);
	if(size(clones) == 1) return clones[0]; 
	
	assert all(Clone clone <- clones, clone.filename == head(clones).filename);
	
	Clone clone1 = head(clones);
	Clone clone2 = last(take(2, clones));
	list[Clone] remaining = drop(2, clones);
	
	Clone mergedClone = mergeClones(clone1, clone2);

	return mergeClones(mergedClone + remaining);
}

public Clone mergeClones(Clone clone1, Clone clone2) 
{
	assert clone1.filename == clone2.filename;
	
	list[CodeLine] lines = dup(clone1.lines + clone2.lines);
	
	return clone(clone1.cloneClassIdentifier, clone1.cloneId, clone1.filename, lines);
}

//
// Gets the range of a clone. 
//
public list[int] cloneRange(Clone clone) 
{
	return [ codeLine.orderNumber | codeLine <- clone.lines ];
}

//
// Determines whether to ranges are adjacent or overlap each other.
//
public bool rangesAreAdjacentOrOverlaps(list[int] range1, list[int] range2) 
{
	range1 += max(range1) + 1;
	range1 += min(range1) - 1;
	
	return !isEmpty(range1 & range2);
}


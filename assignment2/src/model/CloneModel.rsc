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

//
// Tries to make the largset possible clones in a clone model.
//
public CloneModel normalizeCloneModel(CloneModel model) 
{
	list[loc] files = getFilesFromCloneModel(model);
	
	for(file <- files) 
	{
		// List of clones from the same file.
		list[CloneFragment] clones = getClonesFromFile(model, file);
		
		// Maak de grootste mogelijke clones.
		list[CloneFragment] largestPossibleClones = consolidateClones(clones);
		
		// Maak alle mogelijke subclones.
		
		
		 
	}
	
	
	// Vergelijk alle subclones met elkaar. Filter weg wat geen clone is.
	
	// 
}

public list[CloneFragment] consolidateClones(list[CloneFragment] clones)
{
	CloneFragment first = head(clones);
	list[CloneFragment] tail = tail(clones);

	// Select all clones that overlaps with the first
	clonesWithOverlap = [ c | c <- clones, clonesAreAdjacentOrOverlaps(first, c) ];
	remaining = [ c | c <- tail, !clonesAreAdjacentOrOverlaps(first, c) ];

	// Merge the clones with overlap
	CloneFragment mergedClone = mergeClones(clonesWithOverlap); 

	return mergedClone + consolidateClones(remaining);

	

	//while([*CloneFragment nums1, CloneFragment p, *CloneFragment nums2, CloneFragment q, *CloneFragment nums3] := clones && p.cloneIdentifier > q.cloneIdentifier)
	//{
	//	println("Clone <p.cloneIdentifier> and <q.cloneIdentifier>");
	//}
	//return [];
}

public bool alle( list[&T] lst, bool (&T) fn)
{
	return all(mapper( lst, fn));
}


private bool clonesAreAdjacentOrOverlaps(CloneFragment clone1, CloneFragment clone2) 
{
	list[int] range1 = cloneRange(clone1);
	list[int] range2 = cloneRange(clone2);
	
	return rangesAreAdjacentOrOverlaps(range1, range2);
}

//
// Assuming all given clone fragments are from the same file and are adjacent or overlapping each other...
// ... merge all clone fragments into one large fragment.
//
public CloneFragment mergeClones(list[CloneFragment] clones)
{
	if(isEmpty(clones)) return [];
	
	assert all(CloneFragment clone <- clones, clone.lines[0].fileName == first(clones).lines[0].fileName);
	
	
	
	
	return -1;
}

//
// Gets the range of a clone. 
//
public list[int] cloneRange(CloneFragment clone) 
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


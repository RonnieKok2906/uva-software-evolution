module model::CloneModelTests

import Prelude;
import model::CloneModel;
import model::CodeLineModel;

//codeLine(loc fileName, int lineNumber, int orderNumber, str codeFragment);

loc someFile = |file://notRelevant.txt|;

public CloneClass clonesInFile = [
	clone(1, 1, someFile, [codeLine(someFile, 4, 1, ""), codeLine(someFile, 5, 2, ""), codeLine(someFile, 7, 3, ""), codeLine(someFile, 9, 4, "")]),
	// Adjacent to the first Clone.
	clone(1, 2, someFile, [codeLine(someFile, 10, 5, ""), codeLine(someFile, 11, 6, ""), codeLine(someFile, 13, 7, ""), codeLine(someFile, 14, 8, "")]),
	// Separate Clone.
	clone(1, 3, someFile, [codeLine(someFile, 20, 14, ""), codeLine(someFile, 21, 15, ""), codeLine(someFile, 25, 16, ""), codeLine(someFile, 27, 17, "")]),
	// Overlapping with the 3rd Clone.
	clone(1, 4, someFile, [codeLine(someFile, 25, 16, ""), codeLine(someFile, 27, 17, ""), codeLine(someFile, 28, 18, ""), codeLine(someFile, 30, 19, "")])
];

test bool testGetFilesFromCloneModel()
{
	// Arrange
	list[loc] expected = [|file://notRelevant.txt|];
	CloneModel cloneModel = (1:clonesInFile);
	
	// Act
	list[loc] actual = getFilesFromCloneModel(cloneModel);
	
	// Assert
	return expected == actual;
}

test bool testGetClonesFromFile() 
{
	// Arrange
	CloneModel cloneModel = (1:clonesInFile);
	loc filename = |file://notRelevant.txt|;
	
	// Act 
	list[Clone] clones = getClonesFromFile(cloneModel, filename);
	
	// Assert
	return size(clones) == 4;
}


test bool testRangeOverlaps() 
{
	// No overlap
	assert rangesAreAdjacentOrOverlaps([1,2,3], [5,6,7]) == false;
	// With overlap
	assert rangesAreAdjacentOrOverlaps([1,2,3], [3,4,5]) == true;
	// Adjacent
	assert rangesAreAdjacentOrOverlaps([1,2,3], [4,5,6]) == true;

	// No overlap
	assert rangesAreAdjacentOrOverlaps([3,2,1], [5,7,6]) == false;
	// With overlap
	assert rangesAreAdjacentOrOverlaps([2,3,1], [4,3,5]) == true;
	// Adjacent
	assert rangesAreAdjacentOrOverlaps([2,3,1], [6,4,5]) == true;
	
	return true;
}
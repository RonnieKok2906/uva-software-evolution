module model::CloneModelTests

import model::CloneModel;
import model::CodeLineModel;

//codeLine(loc fileName, int lineNumber, int orderNumber, str codeFragment);

loc someFile = |file://notRelevant.txt|;

public list[CloneFragment] clonesInFile = [
	<1, 1, [codeLine(someFile, 4, 1, ""), codeLine(someFile, 5, 2, ""), codeLine(someFile, 7, 3, ""), codeLine(someFile, 9, 4, "")]>,
	<1, 2, [codeLine(someFile, 10, 5, ""), codeLine(someFile, 11, 6, ""), codeLine(someFile, 13, 7, ""), codeLine(someFile, 14, 8, "")]>
];



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
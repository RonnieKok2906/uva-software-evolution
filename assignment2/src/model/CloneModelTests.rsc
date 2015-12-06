module model::CloneModelTests

import model::CloneModel;

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
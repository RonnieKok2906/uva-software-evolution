module volume::VolumeTests

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import model::MetricTypes;
import model::CodeLineModel;
import volume::Volume;

test bool testVolumeWithCommentsAndEmptyLines()
{
	// Arrange
	loc file = |project://testSource/src/TestComplexityWithCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	// Act
	LOC actual = projectVolume(codeLineModel);
	
	// Assert
	LOC expected = 79;	

	return actual == expected;
}

test bool testVolumeWithoutCommentsAndEmptyLines()
{
	// Arrange
	loc file = |project://testSource/src/TestComplexityWithoutCommentsAndEmptyLines.java|;
	M3 m3Model = createM3FromEclipseFile(file);
	
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);

	// Act
	LOC actual = projectVolume(codeLineModel);
	
	// Assert
	LOC expected = 79;	

	return actual == expected;
}

test bool convertLOCToPlusPlus() = all(x <- [-1..66001], convertLOCToRankForJava(x) == plusPlus());
test bool convertLOCToPlus() = all(x <- [66001..246001], convertLOCToRankForJava(x) == plus());
test bool convertLOCToNeutral() = all(x <- [246001..665001], convertLOCToRankForJava(x) == neutral());
test bool convertLOCToMinus() = all(x <- [665001, 665011..1310001], convertLOCToRankForJava(x) == minus());
test bool convertLOCToMinusMinus() = all(x <- [1310001, 1310010..2000000], convertLOCToRankForJava(x) == minusMinus());

public list[bool] allTests() = [
								testVolumeWithCommentsAndEmptyLines(),
								testVolumeWithoutCommentsAndEmptyLines(),
								convertLOCToPlusPlus(),
								convertLOCToPlus(),
								convertLOCToNeutral(),
								convertLOCToMinus(),
								convertLOCToMinusMinus()
								];
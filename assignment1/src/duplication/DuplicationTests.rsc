module duplication::DuplicationTests

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import model::MetricTypes;
import model::CodeLineModel;
import duplication::Duplication;

public list[bool] allTests() = [
								testSourceIsDuplicated(),
								testSourceIsMinusMinus()
								]; 

test bool testSourceIsDuplicated()
{
	// Arrange
	loc testProject = |project://testSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	CodeLineModel model = createCodeLineModel(m3Model);
	
	// Act
	DuplicationMetric actual = projectDuplication(model);
	
	// Assert
	int expectedNumberOfDuplicatedLines = 154;
	int expectedNumberOfTotalLines = 158;
	
	return actual[0] == expectedNumberOfDuplicatedLines 
		&& actual[1] == expectedNumberOfTotalLines;
}

test bool testSourceIsMinusMinus()
{
	// Arrange
	loc testProject = |project://testSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	CodeLineModel model = createCodeLineModel(m3Model);
	
	// Act
	DuplicationMetric result = projectDuplication(model);
	
	// Assert
	Rank expectedRank = minusMinus();
	return convertPercentageToRank(result) == expectedRank;
}
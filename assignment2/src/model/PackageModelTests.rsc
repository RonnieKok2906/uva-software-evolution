module model::PackageModelTests

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import model::PackageModel;
import model::CodeLineModel;

public list[bool] allTests() = [
								testThatCloneSourceHasThreeChildPackagesRelation(),
								testThatCloneSourceHasThreeChildPackages(),
								testThatCloneSourceHasTwoRootPackages(),
								testThatCloneSourceHasFivePackages(),
								testThatCloneSourceHasCorrectNumberOfLines()
								];

test bool testThatCloneSourceHasThreeChildPackagesRelation()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	// Act
	rel[loc, loc] childPackageRelation = getChildPackageRelation(m3Model);
	
	// Assert
	return size(childPackageRelation) == 3 ;
}

test bool testThatCloneSourceHasThreeChildPackages()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	// Act
	set[loc] childPackages = getChildPackages(m3Model);
	
	// Assert
	return size(childPackages) == 3 ;
}

test bool testThatCloneSourceHasTwoRootPackages()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
		
	// Act
	set[loc] rootPackages = getRootPackages(m3Model);
	PackageModel model = createPackageModel(m3Model, codeLineModel);
	
	// Assert
	return size(rootPackages) == 2 && size(model) == 2;
}

test bool testThatCloneSourceHasFivePackages()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	// Act
	set[loc] packages = getPackages(m3Model);
	
	// Assert
	return size(packages) == 5;
}

test bool testThatCloneSourceHasCorrectNumberOfLines()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
		
	// Act
	PackageModel model = createPackageModel(m3Model, codeLineModel);
	LOC linesOfCode = (0 | it + p.linesOfCode | p <- model);
	
	// Assert
	return linesOfCode == 124;
}
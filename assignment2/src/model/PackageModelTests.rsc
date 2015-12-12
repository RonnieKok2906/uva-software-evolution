module model::PackageModelTests

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import model::PackageModel;
import model::CodeLineModel;

public list[bool] allTests() = [
								testThatCloneSourceHasCorrectChildPackagesRelation(),
								testThatCloneSourceHasCorrectChildPackages(),
								testThatCloneSourceHasCorrectRootPackages(),
								testThatCloneSourceHasCorrectPackages()
								];

test bool testThatCloneSourceHasCorrectChildPackagesRelation()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	// Act
	rel[loc, loc] childPackageRelation = getChildPackageRelation(m3Model);
	
	// Assert
	return size(childPackageRelation) == 3;
}

test bool testThatCloneSourceHasCorrectChildPackages()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	// Act
	set[loc] childPackages = getChildPackages(m3Model);
	
	// Assert
	return size(childPackages) == 3;
}

test bool testThatCloneSourceHasCorrectRootPackages()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
		
	// Act
	set[loc] rootPackages = getRootPackages(m3Model);
	PackageModel model = createPackageModel(m3Model, codeLineModel);
	
	// Assert
	return size(rootPackages) == 5 && size(model) == 5;
}

test bool testThatCloneSourceHasCorrectPackages()
{
	// Arrange
	loc testProject = |project://testCloneSource|;
	M3 m3Model = createM3FromEclipseProject(testProject);
		
	// Act
	set[loc] packages = getPackages(m3Model);
	
	// Assert
	return size(packages) == 8;
}
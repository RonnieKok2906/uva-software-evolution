module Main

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::PackageModel;
import model::PackageModelTests;
import model::CodeLineModel;
import model::CloneModel;

import type1::Type1;
import type2::Type2;
import type2::CodeLineModel2;

import visualisation::HTMLTests;

import visualisation::Visualisation;

CloneFragment original = <1, 1, [
						codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	7, "	void sumProd1a(int n){"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	8, "	double sum = 0.0;//C1"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	9, "	double prod = 1.0;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	10, "	for (int i = 1; i \<= n; i++)"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	11, "		{sum = sum + i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	12, "		prod = prod * i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	13, "		foo(sum, prod); }}")
]>;

CloneFragment clone1A = <1, 2, [
						codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	16, "	void sumProd1a(int n){"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	17, "	double sum = 0.0;//C1"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	18, "	double prod = 1.0;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	19, "	for (int i = 1; i \<= n; i++)"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	20, "			{sum = sum + i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	21, "			prod = prod * i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/Originaland1Aand3C.java|,
	22, "			foo(sum, prod); }}")
]>;

CloneFragment clone1B = <1, 3, [
						codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1B.java|,
	5, "	void sumProd1a(int n){"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1B.java|,
	6, "	double sum = 0.0;//C1\'"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1B.java|,
	7, "	double prod = 1.0;//C"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1B.java|,
	8, "	for (int i = 1; i \<= n; i++)"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1B.java|,
	9, "		{sum = sum + i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1B.java|,
	10, "		prod = prod * i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1B.java|,
	11, "		foo(sum, prod); }}")
]>;

CloneFragment clone1C = <1, 4, [
						codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1C.java|,
	6, "	void sumProd1a(int n){"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1C.java|,
	7, "	double sum = 0.0;//C1\'"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1C.java|,
	8, "	double prod = 1.0;//C"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1C.java|,
	9, "	for (int i = 1; i \<= n; i++) {"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1C.java|,
	10, "		sum = sum + i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1C.java|,
	11, "		prod = prod * i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage/CloneType1C.java|,
	12, "		foo(sum, prod); }}")
]>;

CloneFragment clone2C = <1, 5, [
						codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage2/child/CloneType2C.java|,
	6, "	void sumProd1a(int n){"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage2/child/CloneType2C.java|,
	7, "	double sum = 0;//C1\'"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage2/child/CloneType2C.java|,
	8, "	double prod = 1;//C"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage2/child/CloneType2C.java|,
	9, "	for (int i = 1; i \<= n; i++) {"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage2/child/CloneType2C.java|,
	10, "		sum = sum + i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage2/child/CloneType2C.java|,
	11, "		prod = prod * i;"),
	codeLine(|file:///Users/tonheijligers/Documents/WorkspaceSE/uva-software-evolution/testCloneSource/src/clonePackage2/child/CloneType2C.java|,
	12, "		foo(sum, prod); }}")
]>;

public CloneModel myCloneClasses = (
	0:[original, clone1A, clone1B, clone1C, clone2C]
);


public list[loc] projects()
{
	return [|project://smallsql0.21_src|, |project://hsqldb-2.3.1|, |project://testCloneSource|];
}

public void detectClones(loc project)
{
	println("Building M3 model for project...");
	M3 m3Model = createM3FromEclipseProject(project);

	println("Building AST model for project...");
	set[Declaration] declarations = createAstsFromEclipseProject(project, false);
	
	println("Building CodeLineModel...");
	CodeLineModel codeLineModel = createCodeLineModel(m3Model);
	
	println("Building PackageModel...");
	PackageModel packageModel = createPackageModel(m3Model, codeLineModel);

	//Type 1
	println("Building cloneModelType1...");
	CloneModel cloneModelType1 = type1::Type1::clonesInProject(codeLineModel);

	println("Building visualisation Type1..");
	createVisualisation(project.authority, packageModel, codeLineModel, cloneModelType1, type1());
	
	//Type 2
	println("Building CodeLineModel2...");
	CodeLineModel2 codeLineModel2 = type2::CodeLineModel2::createCodeLineModel(m3Model);
	
	println("Building cloneModelType2...");
	CloneModel cloneModelType2 = type2::Type2::clonesInProject(codeLineModel2, declarations);

	println("Building visualisation Type2..");
	createVisualisation(project.authority, packageModel, codeLineModel, cloneModelType2, type2());
}

//Test Functions
public void runAllTests()
{
	list[tuple[str,list[bool]]] tests = [
								<"CodeLineModel.rsc Tests", model::CodeLineModel::allTests()>,
								<"PackageModelTests.rsc Tests", model::PackageModelTests::allTests()>,
								<"HTMLTests.rsc Tests", visualisation::HTMLTests::allTests()>
								];

	int numberOfFailedTests = 0;
	int numberOfPassedTests = 0;
	
	println("-----------------------------------------------------------");
	
	for (<name, subTests> <- tests)
	{
		tuple[int passed, int failed] result = runTests(subTests);
		numberOfPassedTests += result.passed;
		numberOfFailedTests += result.failed;
		println("<name> : <result.passed> passed, <result.failed> failed");
	}
	
	println("-----------------------------------------------------------");
	println("TEST REPORT:<numberOfPassedTests> passed, <numberOfFailedTests> failed");
	println("-----------------------------------------------------------");
}

//Function to run a list of tests
public tuple[int passed, int failed] runTests(list[bool] tests)
{
	int numberOfTests = size(tests);
	int passedTests = size([t | t <- tests, t == true]);
	return <passedTests, numberOfTests - passedTests>;
}
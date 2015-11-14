module Util

import Prelude;

import lang::java::jdt::m3::AST;

import model::MetricTypes;
import model::CodeUnitModel;

//Accumulated Lines of Code of a list of MetricTypes::Unit.  
public LOC linesOfCodeOfUnitList([]) = 0;
public LOC linesOfCodeOfUnitList(list[Unit] units) = sum([size(u.lines) | u <- units]);

//Accumulated Lines of Code of a set of MetricTypes::Unit.
public LOC linesOfCodeOfUnitList({}) = 0;
public LOC linesOfCodeOfUnitList(set[Unit] units) = sum([size(u.lines) | u <- units]);


//Function to run a list of tests
public tuple[int passed, int failed] runTests(list[bool] tests)
{
	int numberOfTests = size(tests);
	int passedTests = size([t | t <- tests, t == true]);
	return <passedTests, numberOfTests - passedTests>;
}
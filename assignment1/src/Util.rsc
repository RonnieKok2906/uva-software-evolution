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
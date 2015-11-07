module MetricTypes

import lang::java::jdt::m3::AST;

alias CodeFragment = str;
alias LOC = int;
alias CC = int;

data Unit = unit(loc fileName, loc location, list[Statement] statements, LOC linesOfCode);
data Comment = comment(loc location);
data ComplexityRiskEvaluation = simple() | moreComplex() | complex() | untestable();
data Rank = plusPlus() | plus() | neutral() | minus() | minusMinus();

data MaintainabilityMetric = analysability() | changeability() | stability() | testability();
data SourceCodeProperty = volume(Rank rank) | complexityPerUnit(Rank rank) | duplication(Rank rank) | unitSize(Rank rank) | unitTesting(Rank rank);
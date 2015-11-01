module MetricTypes

alias UnitName = str;
alias CodeFragment = str;
alias LOC = int;
alias CC = int;

data Unit = unit(UnitName unitName, CodeFragment codeFragment);

data ComplexityRiskEvaluation = simple() | moreComplex() | complex() | untestable();
data Rank = plusPlus() | plus() | neutral() | minus() | minusMinus();

data MaintainabilityMetric = analysability() | changeability() | stability() | testability();
data SourceCodeProperty = volume(Rank rank) | complexityPerUnit(Rank rank) | duplication(Rank rank) | unitSize(Rank rank) | unitTesting(Rank rank);
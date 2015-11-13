module model::MetricTypes

alias LOC = int;
alias CC = int;

data Comment = comment(loc location);
alias CodeFragment = str;
data CodeLine = codeLine(loc fileName, int lineNumber, CodeFragment codeFragment);
alias CodeBlock = list[CodeLine];

data ComplexityRiskEvaluation = simple() | moreComplex() | complex() | untestable();
data UnitSizeEvaluation = veryHigh() | high() | medium() | low();
data Rank = plusPlus() | plus() | neutral() | minus() | minusMinus();

data MaintainabilityMetric = analysability() | changeability() | stability() | testability();
data SourceCodeProperty = volume(Rank rank) | complexityPerUnit(Rank rank) | duplication(Rank rank) | unitSize(Rank rank) | unitTesting(Rank rank);


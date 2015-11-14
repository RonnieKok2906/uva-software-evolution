module model::MetricTypes

alias LOC = int;
alias CC = int;

data Comment = comment(loc location);
data CodeLine = codeLine(loc fileName, int lineNumber, str codeFragment);


data UnitSizeEvaluation = veryHigh() | high() | medium() | low();
data Rank = plusPlus() | plus() | neutral() | minus() | minusMinus();
public list[Rank] ranks = [plusPlus(), plus(), neutral(), minus(), minusMinus()];

data MaintainabilityMetric = analysability() | changeability() | stability() | testability();
data SourceCodeProperty = volume(Rank rank) | complexityPerUnit(Rank rank) | duplication(Rank rank) | unitSize(Rank rank) | unitTesting(Rank rank);
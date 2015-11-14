module model::MetricTypes

alias LOC = int;
alias CC = int;

data Comment = comment(loc location);
data CodeLine = codeLine(loc fileName, int lineNumber, str codeFragment);

data Rank = plusPlus() | plus() | neutral() | minus() | minusMinus() | undefined();
public list[Rank] ranks = [plusPlus(), plus(), neutral(), minus(), minusMinus()];

public str convertRankToString(plusPlus()) = "++";
public str convertRankToString(plus()) = "+";
public str convertRankToString(neutral()) = "o";
public str convertRankToString(minus()) = "-";
public str convertRankToString(minusMinus()) = "--";
public str convertRankToString(undefined()) = "undefined";

data MaintainabilityMetric = analysability() | changeability() | stability() | testability();
data SourceCodeProperty = volume(Rank rank) | complexityPerUnit(Rank rank) | duplication(Rank rank) | unitSize(Rank rank) | unitTesting(Rank rank);
module volume::VolumeConversion

import model::MetricTypes;
import volume::Volume;

//Test functions
test bool convertLOCToPlusPlus() = all(x <- [-1..66001], convertLOCToRankForJava(x) == plusPlus());
test bool convertLOCToPlus() = all(x <- [66001..246001], convertLOCToRankForJava(x) == plus());
test bool convertLOCToNeutral() = all(x <- [246001..665001], convertLOCToRankForJava(x) == neutral());
test bool convertLOCToMinus() = all(x <- [665001, 665011..1310001], convertLOCToRankForJava(x) == minus());
test bool convertLOCToMinusMinus() = all(x <- [1310001, 1310010..2000000], convertLOCToRankForJava(x) == minusMinus());

public list[bool] allTests() = [
								convertLOCToPlusPlus(),
								convertLOCToPlus(),
								convertLOCToNeutral(),
								convertLOCToMinus(),
								convertLOCToMinusMinus()
								];
module complexity::ComplexityConversion

import MetricTypes;

//Complexity Conversion functions

//Conversion from Cyclomatic Complexity to an enumerated Risk Evaluation
private ComplexityRiskEvaluation convertCCToComplexityRiskEvalutation(CC c) = untestable() when c > 50;
private ComplexityRiskEvaluation convertCCToComplexityRiskEvalutation(CC c) = complex() when c > 20 && c <= 50;
private ComplexityRiskEvaluation convertCCToComplexityRiskEvalutation(CC c) = moreComplex() when c > 10 && c <= 20;
private default ComplexityRiskEvaluation convertCCToComplexityRiskEvalutation(CC c) = simple();

test bool convertCCToSimple1() = all(x <- [-1..11], convertCCToComplexityRiskEvalutation(x) == simple());
test bool convertCCToMoreComplex() = all(x <- [11..21], convertCCToComplexityRiskEvalutation(x) == moreComplex());
test bool convertCCToComplex() = all(x <- [21..51], convertCCToComplexityRiskEvalutation(x) == complex());
test bool convertCCToUntestable() = all(x <- [51..100], convertCCToComplexityRiskEvalutation(x) == untestable());


//Conversion from a complexity risk pie to an enumerated Rank
private Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = minusMinus() 
	when pie[moreComplex()] > 0.5 || pie[complex()] > 0.15 || pie[untestable()] > 0.05;
	
private Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = minus() 
	when pie[moreComplex()] > 0.4 || pie[complex()] > 0.10 || pie[untestable()] > 0.0;
	
private Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = neutral() 
	when pie[moreComplex()] > 0.3 || pie[complex()] > 0.05 || pie[untestable()] > 0.0;
	
private Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = plus() 
	when pie[moreComplex()] > 0.25 || pie[complex()] > 0.0 || pie[untestable()] > 0.0;
	
private default Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = plusPlus();


test bool convertPieToPlusPlus() = all(
										a <- [-1.0, -0.95..0.25], b <- [-1.0, -0.99..0.0], c <- [-1.0, -0.99..0.0], 
										convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == plusPlus()
										);
										
test bool convertPieToPlus1() = all(
									a <- [0.26, 0.27..0.3], b <- [-1.0, -0.99..0.05], c <- [0.0], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == plus()
									);
test bool convertPieToPlus2() = all(
									a <- [0.0, 0.01..0.3], b <- [0.01, 0.02..0.05], c <- [0.0], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == plus()
									);
test bool convertPieToPlus3() = all(
									a <- [0.26, 0.27..0.3], b <- [0.01, 0.02..0.05], c <- [0.0], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == plus()
									);

									
test bool convertPieToNeutral1() = all(
									a <- [0.0, 0.01..0.4], b <- [0.06, 0.07..0.1], c <- [0.0], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == neutral()
									);
test bool convertPieToNeutral2() = all(
									a <- [0.31, 0.32..0.4], b <- [0.0, 0.01..0.1], c <- [0.0], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == neutral()
									);
test bool convertPieToNeutral3() = all(
									a <- [0.31, 0.32..0.4], b <- [0.06, 0.07..0.1], c <- [0.0], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == neutral()
									);

																		
test bool convertPieToMinus1() = all(
									a <- [0.0, 0.01..0.5], b <- [0.11, 0.12..0.15], c <- [0.0, 0.01..0.05], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == minus()
									);
test bool convertPieToMinus2() = all(
									a <- [0.41, 0.42..0.5], b <- [0.0, 0.01..0.15], c <- [0.0, 0.01..0.05], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == minus()
									);
test bool convertPieToMinus3() = all(
									a <- [0.41, 0.42..0.5], b <- [0.11, 0.12..0.15], c <- [0.0, 0.01..0.05], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == minus()
									);
									

test bool convertPieToMinusMinus1() = all(
									a <- [0.0, 0.01..1.0], b <- [0.16, 0.17..0.30], c <- [0.05, 0.06..0.2], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == minusMinus()
									);
test bool convertPieToMinusMinus2() = all(
									a <- [0.51, 0.52..1.0], b <- [0.0, 0.01..0.30], c <- [0.05, 0.06..0.2], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == minusMinus()
									);
test bool convertPieToMinusMinus3() = all(
									a <- [0.51, 0.52..1.0], b <- [0.16, 0.17..0.30], c <- [0.0, 0.01..0.2], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == minusMinus()
									);
test bool convertPieToMinusMinus4() = all(
									a <- [0.51, 0.52..1.0], b <- [0.16, 0.17..0.30], c <- [0.05, 0.06..0.2], 
									convertPieToRank((moreComplex() : a, complex() : b, untestable() : c)) == minusMinus()
									);
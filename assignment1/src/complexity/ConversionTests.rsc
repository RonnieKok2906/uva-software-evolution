module complexity::ConversionTests

import Prelude;
import util::Math;
import model::MetricTypes;
import complexity::Conversion;


test bool convertCCToSimple() = all(x <- [-1..11], convertCCToComplexityRiskEvalutation(x) == simple());
test bool convertCCToMoreComplex() = all(x <- [11..21], convertCCToComplexityRiskEvalutation(x) == moreComplex());
test bool convertCCToComplex() = all(x <- [21..51], convertCCToComplexityRiskEvalutation(x) == complex());
test bool convertCCToUntestable() = all(x <- [51..100], convertCCToComplexityRiskEvalutation(x) == untestable());


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

public list[bool] allTests() = [	
									convertCCToSimple(),
									convertCCToMoreComplex(),
									convertCCToComplex(),
									convertCCToUntestable(),
									convertPieToPlusPlus(),
									convertPieToPlus1(),
									convertPieToPlus2(),
									convertPieToPlus3(),
									convertPieToNeutral1(),
									convertPieToNeutral2(),
									convertPieToNeutral3(),
									convertPieToMinus1(),
									convertPieToMinus2(),
									convertPieToMinus3(),
									convertPieToMinusMinus1(),
									convertPieToMinusMinus2(),
									convertPieToMinusMinus3()
								];
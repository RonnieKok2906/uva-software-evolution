module complexity::Conversion

import Prelude;

import model::MetricTypes;

data ComplexityRiskEvaluation = simple() | moreComplex() | complex() | untestable();
list [ComplexityRiskEvaluation] cre = [simple(), moreComplex(), complex(), untestable()];

public str convertCREToString(simple()) = "simple";
public str convertCREToString(moreComplex()) = "more complex";
public str convertCREToString(complex()) = "complex";
public str convertCREToString(untestable()) = "untestable";


//Complexity Conversion functions

public void printRankTable(map[ComplexityRiskEvaluation, real] pie)
{	
	println("\t-----------------------------------------------------------");
	println("\t| Maximum relative LOC");
	println("-------------------------------------------------------------------");
	println("Rank\t| simple\t| complex\t| more complex\t| untestable");
	println("-------------------------------------------------------------------");
	
	for (r <- ranks)
	{
		print("<convertRankToString(r)>\t");

		for (l <- cre)
		{
			real threshold = thresholdsPie[r][l];
			
			if (threshold >= 0.0)
			{
				print("| <threshold>%\t\t");
			}
			else
			{
				print("|  -\t\t");
			}
		}
	
		println();
	
	}
	println("-------------------------------------------------------------------");
	
	
	println("Result\t|");
	println("\t-----------------------------------------------------------");
	print("<convertRankToString(convertPieToRank(pie))>");
	for (l <- cre)
	{
		print("\t| <pie[l]>");
	}
	
	println();
	println("-------------------------------------------------------------------");
	println();
	println();
}

public void printCCTable()
{
	println("-----------------------------------------------------");
	println("CC\t| Risk Evaluation");
	println("-----------------------------------------------------");

	for (c <- cre)
	{	
		LOC to = thresholdsComplexityRisk[c].to;
		
		if (to >= 0)
		{
			println("<thresholdsComplexityRisk[c].from> - <to>\t| <convertCREToString(c)>");
		}
		else
		{
			println("  \><thresholdsComplexityRisk[c].from> \t| <convertCREToString(c)>");
		}
	}
	println("-----------------------------------------------------");
	
	println();
}

//Conversion from Cyclomatic Complexity to an enumerated Risk Evaluation
public ComplexityRiskEvaluation convertCCToComplexityRiskEvalutation(CC c) = simple() when c <= thresholdsComplexityRisk[simple()].to;
public ComplexityRiskEvaluation convertCCToComplexityRiskEvalutation(CC c) = moreComplex() when c <= thresholdsComplexityRisk[moreComplex()].to;
public ComplexityRiskEvaluation convertCCToComplexityRiskEvalutation(CC c) = complex() when c <= thresholdsComplexityRisk[complex()].to;
public default ComplexityRiskEvaluation convertCCToComplexityRiskEvalutation(CC c) = untestable();


//Conversion from a complexity risk pie to an enumerated Rank
public default Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = plusPlus()
	when pieDoesConformToRank(plusPlus(), pie);
public default Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = plus()
	when pieDoesConformToRank(plus(), pie);
public default Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = neutral()
	when pieDoesConformToRank(neutral(), pie);		
public default Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = minus()
	when pieDoesConformToRank(minus(), pie);
public default Rank convertPieToRank(map[ComplexityRiskEvaluation, real] pie) = minusMinus();

private bool pieDoesConformToRank(Rank rank, map[ComplexityRiskEvaluation, real] pie)
{
	return (pie[moreComplex()] <= thresholdsPie[rank][moreComplex()] &&
			pie[complex()] <= thresholdsPie[rank][complex()] && 
			pie[untestable()] <= thresholdsPie[rank][untestable()]);
}

private map[ComplexityRiskEvaluation, tuple[LOC from, LOC to]] thresholdsComplexityRisk = (
																						simple() : <0, 10>,
																						moreComplex() : <10, 20>,
																						complex() : <20, 50>,
																						untestable() : <50, -1>
																						);

private map[Rank, map[ComplexityRiskEvaluation, real]] thresholdsPie = (
																		plusPlus() : (simple() : -1.0, moreComplex() : 0.25, complex() : 0.0, untestable() : 0.0),
																		plus() :  (simple() : -1.0, moreComplex() : 0.3, complex() : 0.05, untestable() : 0.0),
																		neutral() : (simple() : -1.0, moreComplex() : 0.4, complex() : 0.1, untestable() : 0.0),
																		minus() :  (simple() : -1.0, moreComplex() : 0.5, complex() : 0.15, untestable() : 0.5),
																		minusMinus() :  (simple() : -1.0, moreComplex() : -1.0, complex() : -1.0, untestable() : -1.0)
																	);


//Tests Functions
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

//Tests
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


module complexity::Conversion

import Prelude;
import util::Math;

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
	println("\t--------------------------------------------------------------");
	println("\t| Maximum relative LOC");
	println("----------------------------------------------------------------------");
	println("Rank\t| simple\t| complex\t| more complex\t| untestable");
	println("----------------------------------------------------------------------");
	
	for (r <- ranks)
	{
		print("<convertRankToString(r)>\t");

		for (l <- cre)
		{
			real threshold = thresholdsPie[r][l];
			
			if (threshold >= 0.0)
			{
				print("| <toInt(round(threshold * 100.0))>%\t\t");
			}
			else
			{
				print("|  -\t\t");
			}
		}
	
		println();
	
	}
	println("----------------------------------------------------------------------");
	
	
	println("Result\t|");
	println("\t--------------------------------------------------------------");
	print("<convertRankToString(convertPieToRank(pie))>");
	for (l <- cre)
	{
		print("\t| <toInt(round(pie[l] * 100.0))>%\t");
	}
	
	println();
	println("----------------------------------------------------------------------");
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
																		minus() :  (simple() : -1.0, moreComplex() : 0.5, complex() : 0.15, untestable() : 0.05),
																		minusMinus() :  (simple() : -1.0, moreComplex() : -1.0, complex() : -1.0, untestable() : -1.0)
																	);



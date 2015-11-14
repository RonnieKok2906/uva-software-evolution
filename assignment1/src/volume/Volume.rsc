module volume::Volume

import Prelude;
import model::MetricTypes;
import model::CodeLineModel;

//
// Returns the Volume metric ranking for a given project.
//
public LOC projectVolume(CodeLineModel model)
{
	return (0 | it + size(model[file]) | file <- model);
}

//
// Pretty prints the Volume metrics.  
//
public void printVolume(LOC linesOfCode, Rank ranking) 
{
	println("Volume");
	println("---------");
	println("Total lines of code: <linesOfCode>");
	println();
	println("Volume ranking: <ranking>");	
}


//Conversion from Lines of Code to an enumerated Rank
public Rank convertLOCToRankForJava(LOC l) = plusPlus() when l <= 66000;
public Rank convertLOCToRankForJava(LOC l) = plus() when l <= 246000;
public Rank convertLOCToRankForJava(LOC l) = neutral() when l <= 665000;
public Rank convertLOCToRankForJava(LOC l) = minus() when l <= 1310000;
public default Rank convertLOCToRankForJava(LOC l) = minusMinus();
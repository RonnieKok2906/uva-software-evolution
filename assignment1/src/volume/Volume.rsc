module volume::Volume

import MetricTypes;
import volume::VolumeConversion;

public Rank projectVolume(loc project)
{
	LOC pLoc = projectLinesOfCode(project);

	return convertLOCToRankForJava(pLoc);
}

//TODO: implement
private LOC projectLinesOfCode(loc project)
{
	return 0;
}
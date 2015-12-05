module visualisation::Util

import Prelude;

import model::PackageModel;

public void appendToTempFile(int counter, str string)
{
	loc file = tempFileForCounter(counter);

	appendToFile(file, string);
}

public void writeToTempFile(int counter, str string)
{
	loc file = tempFileForCounter(counter);
	
	loc tempFolder = tempFolder();
	
	if (!exists(tempFolder))
	{
		mkDirectory(tempFolder);
	}
	
	if (!exists(file))
	{	
		resolveLocation(file);
	}

	writeFile(file, string);
}

public str readTempFile(counter) = readFile(tempFileForCounter(counter));

private loc tempFolder() = |project://cloneVisualisation/projects/temp|;

private loc tempFileForCounter(int counter)
{
	loc projectFolder = |project://cloneVisualisation/projects/temp|;
		
	return tempFolder() + "tempFile<counter>.json";
}

private str tempFileWithoutExtesion(int counter)
{	
	return "tempFile<counter>";
}
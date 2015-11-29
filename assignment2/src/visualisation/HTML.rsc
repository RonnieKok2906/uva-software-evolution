module visualisation::HTML

import Prelude;

import model::CodeLineModel;
import model::CloneModel;

public str htmlForCloneClass(CloneFragment cloneFragment, CloneClass cloneClass)
{
	result = "\<h1\>Selected CodeFragment\</h1\>";
	result += "\<h3\><cloneFragment.lines[0].fileName.path>\</h3\>";
	result += htmlForCloneFragment(cloneFragment.lines);
	
	result += "\<h1\>Clones from Selected CodeFragment\</h1\>";
	
	for (c <- cloneClass)
	{
		if (c != cloneFragment)
		{
			result += "\<h3\><c.lines[0].fileName.path>\</h3\>";
			result += htmlForCloneFragment(c.lines);
		}
	}
	
	return result;
}

public str cleanString(str string)
{
	result = replaceLTandGT(string);
	result = replaceDoubleQuotation(result);
	result = replaceSingleQuotation(result);
	result = removeTabs(result);
	result = replaceBackslash(result);
	
	return result;
}


//Private Functions
private str htmlForCloneFragment(list[CodeLine] lines)
{
	str result = "";
	
	result += "\<table\>";
	
	for (l <- lines)
	{
		result += "\<tr\>";
		result += "\<td\>";
		result += "<l.lineNumber>";
		result += "\</td\>";
		result += "\<td\>";
		result += "<cleanString(l.codeFragment)>";
		result += "\</td\>";
		result += "\</tr\>";
	}
	
	result += "\</table\>";
	
	return result;
}



private str replaceLTandGT(str string)
{
	result = replaceAll(string, "\<", "&lt;");
	return replaceAll(result, "\>", "&gt;");
}

private str replaceSingleQuotation(str string)
{
	return replaceAll(string, "\'", "&#8216;");
}

private str replaceDoubleQuotation(str string)
{
	return replaceAll(string, "\"", "&#x22;");
}

private str removeTabs(str string)
{
	list[str] splittedString = split("\t", string);
	
	return ("" | it + s | s <- splittedString);
}

private str replaceBackslash(str string)
{
	return replaceAll(string, "\\", "&#92;");
}
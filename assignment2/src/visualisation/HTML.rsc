module visualisation::HTML

import Prelude;

import model::CodeLineModel;
import model::CloneModel;

public str htmlForCloneClass(Clone cloneFragment, CloneClass cloneClass)
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
	result = removeNewLines(result);
	
	return result;
}


//Private Functions

private str htmlForCloneFragment(list[CodeLine] lines)
{
	str result = "";
	
	result += "\<table\>";
	
	lines = [l | l <- lines, l.hasCode];
	
	for (l <- lines)
	{
		result += "\<tr\>\<td\><l.lineNumber>\</td\>\<td\><cleanString(l.codeFragment)>\</td\>\</tr\>";
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
	return replaceAll(string, "\t", "");
}

private str replaceBackslash(str string)
{
	return replaceAll(string, "\\", "&#92;");
}

private str removeNewLines(str string)
{
	result = replaceAll(string, "\\n", "");
	return replaceAll(result, "\\r", "");
}
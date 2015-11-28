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
		result += "<removeTabs(l.codeFragment)>";
		result += "\</td\>";
		result += "\</tr\>";
	}
	
	result += "\</table\>";
	
	return result;
}

private str removeTabs(str string)
{
	list[str] splittedString = split("\t", string);
	
	return ("" | it + s | s <- splittedString);
}
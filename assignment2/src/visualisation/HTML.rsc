module visualisation::HTML

import Prelude;

import model::CodeLineModel;
import model::CloneModel;

public str htmlForCloneClass(CodeFragment codeFragment, CloneClass cloneClass)
{
	result = "\<h1\>Selected CodeFragment\</h1\>";
	result += "\<h3\><codeFragment[1][0].fileName.path>\</h3\>";
	result += htmlForCodeFragment(codeFragment[1]);
	
	result += "\<h1\>Clones from Selected CodeFragment\</h1\>";
	
	for (c <- cloneClass)
	{
		if (c != codeFragment)
		{
			result += "\<h3\><c[1][0].fileName.path>\</h3\>";
			result += htmlForCodeFragment(c[1]);
		}
	}
	
	return result;
}

private str htmlForCodeFragment(list[CodeLine] lines)
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
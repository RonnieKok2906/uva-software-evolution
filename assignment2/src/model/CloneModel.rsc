module model::CloneModel

import model::CodeLineModel;

alias CodeFragment = tuple[int identifier, list[CodeLine] lines];
alias CloneClass = list[CodeFragment];

alias CloneModel = map[int identifier, CloneClass cloneClass];

public list[CodeFragment] getClonesInCompilationUnit(loc compilationUnit, CloneModel cloneModel)
{
	list[CodeFragment] codeFragments = [];
	
	for (k <- cloneModel)
	{
		for (c <- cloneModel[k])
		{
			if (c[1][0].fileName == compilationUnit.top)
			{
				codeFragments += c;
			}
		}
	}
	
	return codeFragments;
}

public CloneClass cloneClassForCodeFragment(CloneModel cloneModel, CodeFragment codeFragment)
{
	for (c <- cloneModel)
	{
		for (f <- cloneModel[c])
		{
			if (codeFragment == f)
			{
				return cloneModel[c];
			}
		}
	}
	
	return fail;
}
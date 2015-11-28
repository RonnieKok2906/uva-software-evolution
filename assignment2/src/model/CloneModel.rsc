module model::CloneModel

import model::CodeLineModel;

alias CloneFragment = tuple[int cloneClassIdentifier, int cloneIdentifier, list[CodeLine] lines];
alias CloneClass = list[CloneFragment];

alias CloneModel = map[int identifier, CloneClass cloneClass];

public list[CloneFragment] getClonesInCompilationUnit(loc compilationUnit, CloneModel cloneModel)
{
	list[CloneFragment] cloneFragments = [];
	
	for (k <- cloneModel)
	{
		for (c <- cloneModel[k])
		{
			if (c.lines[0].fileName == compilationUnit)
			{
				cloneFragments += c;
			}
		}
	}
	
	return cloneFragments;
}

public CloneClass cloneClassForCloneFragment(CloneModel cloneModel, CloneFragment cloneFragment)
{
	for (c <- cloneModel)
	{
		for (f <- cloneModel[c])
		{
			if (cloneFragment == f)
			{
				return cloneModel[c];
			}
		}
	}
	
	return fail;
}
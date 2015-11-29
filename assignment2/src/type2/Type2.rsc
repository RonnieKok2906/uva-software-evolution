module type2::Type2

import Prelude;
import ListRelation;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import model::CodeLineModel;
import model::CloneModel;


public CloneModel clonesInProject(CodeLineModel model, set[Declaration] declarations)
{
	map[node, set[loc]] allPossibleSubtrees  = ();

	for (d <- declarations)
	{
		allPossibleSubtrees += findSubtreesInDeclaration(d, allPossibleSubtrees);
	}

	CloneModel cloneModel = ();

	int counter = 1;

	for (k <- allPossibleSubtrees)
	{
		int numberOfClones = size(allPossibleSubtrees[k]);
	
		if (numberOfClones > 1)
		{
			loc file = takeOneFrom(allPossibleSubtrees[k])[0];
			
			str string = readFile(file);
			list[str] rawStringLines = ([] | it + split("\r", s) | s <-split("\n",string));
			int numberOfLines = size(rawStringLines);
		
			
			if (numberOfLines > 6)
			{
				counter += 1;
			
				CloneClass cc = createCloneClass(counter, allPossibleSubtrees[k], rawStringLines);
				
				cloneModel[counter] = cc;
			}
		}
	}

	return cloneModel;
}

public CloneClass createCloneClass(int classIdentifier, set[loc] locations, list[str] rawLines)
{
	CloneClass cc = [];

	int counter = 1;
	
	for (l <- locations)
	{
		numberOfFirstLine = l.begin[0];
				
		list[CodeLine] lines = [];
				
		for (i <- [0..size(rawLines)])
		{
			lines += codeLine(l.top, i + numberOfFirstLine, rawLines[i]);
		}
		
		cc += <classIdentifier, counter, lines>;
	}

	return cc;
}

public map[node, set[loc]] findSubtreesInDeclaration(Declaration declaration, map[node, set[loc]] subtrees)
{
	visit(declaration)
	{
		case node n : {
						if (Declaration d := n || Statement d := n || Expression d := n)
						{
							map[str, value] annotations = getAnnotations(n);
						
							if ("src" in annotations)
							{
								
								if (loc source := annotations["src"])
								{
									if (n in subtrees)
									{
										subtrees[d] += source;
									}
									else
									{
										subtrees[d] = {source};
									}
								}
							}
						}
					}
	}

	return subtrees;
}
module typeUtil::TypeUtilTests

import Prelude;
import util::Math;
import typeUtil::TypeUtil;

public list[bool] allTests() = [
								possibleSublistsOfWithMinimumLengthTest(),
								subsequencesTest()
								];

test bool possibleSublistsOfWithMinimumLengthTest()
{
	bool returnValue = true;

	for (i <- [3..8])
	{
		for (j <- [1..i])
		{	
			list[int] testList = [1..i+1];
			list[list[int]] sq = subsequences(testList);
			
			list[list[int]] sqTemp = [];
			
			for (list[int] g <- sq)
			{
				if (size(g) >= j)
				{
					sqTemp += [g];
				}
			}
			
			int numberOfItems = size(sqTemp);
			list[list[int]] sq2 = allPossibleSublistsWithAMinimumNumberOfItems(testList, j);
			int numberOfItems2 = size(sq2);

			returnValue = returnValue && numberOfItems == numberOfItems2;
		}	
	}
	
	return returnValue;
}

test bool subsequencesTest()
{
	bool returnValue = true;

	for (i <- [2..6])
	{
		list[list[int]] sq = subsequences([1..i+1]);
		int numberOfItems = size(sq);
		
		bool temp = size(sq) == pow(2,i) - 1;
		returnValue = returnValue && temp;
	}
	
	return returnValue;
}
module visualisation::HTMLTests

import visualisation::HTML;

public list[bool] allTests() = [
								testThatLTIsReplacedWithHTMLEntity(),
								testThatLGIsReplacedWithHTMLEntity(),
								testThatDoubleQuotionIsReplacedWithHTMLEntity(),
								testThatTabsAreRemoved(),
								testThatBackslashIsReplacedWithHTMLEntity(),
								testThatCombinedSpecialCharactersIsCleanedCorrectly()
							];
								
								
test bool testThatLTIsReplacedWithHTMLEntity()
{
	return cleanString("\<") == "&lt;";
}

test bool testThatLGIsReplacedWithHTMLEntity()
{	
	return cleanString("\>") == "&gt;";
}

test bool testThatDoubleQuotionIsReplacedWithHTMLEntity()
{	
	return cleanString("\"") == "&#x22;";
}

test bool testThatSingleQuotionIsReplacedWithHTMLEntity()
{	
	return cleanString("\'") == "&#8216;";
}

test bool testThatTabsAreRemoved()
{	
	return cleanString("\t\t\t	") == "";
}

test bool testThatBackslashIsReplacedWithHTMLEntity()
{
	return cleanString("\\") == "&#92;";
}

test bool testThatCombinedSpecialCharactersIsCleanedCorrectly()
{
	str string = "\<\\\>\"	\"\'";
	
	str reference = "&lt;&#92;&gt;&#x22;&#x22;&#8216;";
	
	return cleanString(string) == reference;
}
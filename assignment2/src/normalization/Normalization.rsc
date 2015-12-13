module normalization::Normalization

import Prelude;

import lang::java::jdt::m3::AST;

import normalization::Config;

import typeUtil::TypeUtil;
import model::CodeLineModel;

public map[node, set[loc]] findAllRelevantNormalizedSubtrees(set[Declaration] declarations, Config config)
{
	map[node, set[loc]] subtrees = ();

	for (d <- declarations)
	{				
		visit(d)
		{
			case node n : 
			{
				if (isCloneSubtreeCandidate(n))
				{
					subtrees = addNodeToSubtrees(normalizeNode(n, config), subtrees);
				}
			}
		}
	}
	
	return subtrees;
}

public map[int, list[list[CodeLine]]] findSubblocks(set[Declaration] declarations, Config config, CodeLineModel codeLineModel)
{
	map[list[node], list[list[CodeLine]]] intermediateResult = ();

	for (d <- declarations)
	{				
		visit(d)
		{
			case b:\block(statements) : 
			{
				intermediateResult = generateSubblocks(statements, intermediateResult, codeLineModel, config);
			}
			case t:\try(body, statements) :
			{	
				intermediateResult = generateSubblocks(statements, intermediateResult, codeLineModel, config);
			}
			case t:\try(body, statements, finallyBody) :
			{
				intermediateResult = generateSubblocks(statements, intermediateResult, codeLineModel, config);
			}
		}
	}
	
	map[int, list[list[CodeLine]]] returnMap = ();
	
	counter = 0;
	for (i <- intermediateResult)
	{
		if (size(intermediateResult[i]) > 1)
		{
			returnMap += (counter:intermediateResult[i]);
		
			counter += 1;
		}
	}
	
	return returnMap;
}

private map[int, list[list[CodeLine]]] addLeadingStatements(map[int, list[list[CodeLine]]] returnMap, Statement parentNode, list[Statement] statements, CodeLineModel codeLineModel, Config config)
{
	list[list[node]] leadingStatements = findPossibleLeadingSubblocks(statements);
	
	int ni = newIdentifier(toList(domain(returnMap)));
	
	int rootNodeBegin = parentNode.begin[0];
	
	loc fileName = statements[0]@src;
	
	for (ls <- leadingStatements)
	{
		int lastLine = last(ls)@src.end[0];
		
		returnMap[ni] = [l | i <- [rootNodeBegin..lastLine+1], l := codeLineModel[fileName][i]];
	}

	return returnMap;
}

map[list[node], list[list[CodeLine]]] generateSubblocks(list[node] statements, map[list[node], list[list[CodeLine]]] intermediateResult, CodeLineModel codeLineModel, Config config)
{
	if (size(statements) > 1)
	{
		list[list[node]] subblocks = findPossibleSubblocks(statements);
		subblocks = [[normalizeNode(i, config) | i <- s] |s <- subblocks];
		intermediateResult = addSubBlockToIntermediateResult(intermediateResult, subblocks, codeLineModel);
	}
	
	return intermediateResult;
}

private map[list[node], list[list[CodeLine]]] addSubBlockToIntermediateResult(map[list[node], list[list[CodeLine]]] intermediateResult, list[list[node]] subblocks, CodeLineModel codeLineModel)
{
	map[list[node], list[list[CodeLine]]] returnMap = intermediateResult;

	for (s <- subblocks)
	{
		if (s in intermediateResult)
		{
			returnMap[s] += [codeLinesForStatements(s, codeLineModel)];
		}
		else
		{
			returnMap[s] = [codeLinesForStatements(s, codeLineModel)];
		}
	}
	
	return returnMap;
}

private list[CodeLine] codeLinesForStatements(list[node] statements, CodeLineModel codeLineModel)
{
	if (Statement s1 := statements[0] && Statement s2 := last(statements))
	{
		int firstLineNumber = s1@src.begin[0];
		int lastLineNumber = s2@src.end[0];
		
		assert(firstLineNumber <= lastLineNumber);
		
		return [codeLineModel[s1@src.top][i] | i <- [firstLineNumber.. lastLineNumber + 1]];
	}	
	else
	{
		assert(false);
	}
	
	return [];
}

private list[list[&T]] findPossibleLeadingSubblocks(list[&T] statements)
{
	int numberOfStatements = size(statements);
	
	list[list[&T]] returnList = [];
	
	for (i <- [1..numberOfStatements])
	{
		returnList +=  [[statements[k] | k <- [0..i]]];
	}
	
	return returnList;
}

private list[list[&T]] findPossibleTrainlingSubblocks(list[&T] statements)
{
	int numberOfStatements = size(statements);
	
	list[list[&T]] returnList = [];
	
	for (i <- [1..numberOfStatements])
	{
		returnList +=  [[statements[k] | k <- [i..numberOfStatements + 1]]];
	}
	
	return returnList;
}

private list[list[&T]] findPossibleSubblocks(list[&T] statements)
{
	int numberOfStatements = size(statements);
	
	list[list[&T]] returnList = [];
	
	for (i <- [2..numberOfStatements])
	{
		for (j <- [0..numberOfStatements - i + 1])
		{
			returnList +=  [[statements[k] | k <- [j..j+i]]];
		}
	}
	
	return returnList;
}

private node normalizeNode(node subtree, Config config)
{	
	subtree = visit(subtree)
	{
		case n:\method(_, name, parameters, exceptions, impl) => normalizeMethod(n, config)
    	case n:\method(_, name, parameters, exceptions) => normalizeMethod(n, config)
    	case n:\variables(vType, fragments) => normalizeVariableDeclaration(n, config)
    	case n:\simpleName(_) => normalizeSimpleName(n)
    	case n:\characterLiteral(str charValue) => normalizeCharacterLiteral(n, config)
    	case n:\number(_) => normalizeNumberLiteral(n, config)
    	case n:\booleanLiteral(_) => normalizeBooleanLiteral(n, config)
    	case n:\stringLiteral(_) => normalizeStringLiteral(n, config)
    	case n:\variable(name, extraDimensions) => normalizeVariableName(n, config)
    	case n:\variable(name, extraDimensions, initializerExpression) => normalizeVariableNameWithInitializer(n, config)
	}
		
	return subtree;
}

private Declaration normalizeMethod(Declaration methodDeclaration, Config config)
{	
	annotations = getAnnotations(methodDeclaration);

	if (!config.respectMethodReturnType)
	{
		annotations["typ"] = null();
	}	

	if (m:\method(returnType, name, parameters, exceptions, impl) := methodDeclaration)
	{	
		returnType = config.respectMethodReturnType ? returnType : string();
	
		methodDeclaration = \method(returnType, "methodIdentifier", parameters, exceptions, impl);

	}
	else if (m:\method(returnType, name, parameters, exceptions) := methodDeclaration)
	{
		returnType = config.respectMethodReturnType ? returnType : string();
	
		methodDeclaration = \method(returnType, "methodIdentifier", parameters, exceptions);
	}

	methodDeclaration = setAnnotations(methodDeclaration, annotations);
	
	return methodDeclaration;
}

private Expression normalizeSimpleName(Expression simpleNameNode)
{	
	simpleNameNode = setAnnotations(\simpleName("variable"), getAnnotations(simpleNameNode));
	
	return simpleNameNode;
}

private Expression normalizeCharacterLiteral(Expression characterLiteral, Config config)
{
	map[str, value] annotations = getAnnotations(characterLiteral);
	
	if (config.respectLiteralType)
	{
		characterLiteral = \characterLiteral("characterLiteral");
	}
	else
	{
		characterLiteral = \stringLiteral("literal");
		
		annotations["typ"] = string();
	}
		
	characterLiteral = setAnnotations(characterLiteral, annotations);
	
	return characterLiteral;
}

private Expression normalizeNumberLiteral(Expression numberLiteral, Config config)
{
	map[str, value] annotations = getAnnotations(numberLiteral);
	
	if (!config.respectLiteralType)
	{
		annotations["typ"] = string();
		
		numberLiteral = \stringLiteral("literal");
	}
	else if (annotations["typ"] == \int())
	{
		numberLiteral = \number("0");
	}
	else if (annotations["typ"] == \double())
	{
		numberLiteral = \number("0.0");
	}
	
	numberLiteral = setAnnotations(numberLiteral, annotations);

	return numberLiteral;
}

private Expression normalizeBooleanLiteral(Expression booleanLiteral, Config config)
{
	map[str, value] annotations = getAnnotations(booleanLiteral);
	
	if (config.respectLiteralType)
	{
		booleanLiteral = \booleanLiteral(true);
	}
	else
	{
		booleanLiteral = \stringLiteral("literal");
		
		annotations["typ"] = \string();
	}
		
	booleanLiteral = setAnnotations(booleanLiteral, annotations);
	
	return booleanLiteral;
}

private Expression normalizeStringLiteral(Expression sLiteral, Config config)
{
	map[str, value] annotations = getAnnotations(sLiteral);
	
	if (config.respectLiteralType)
	{
		sLiteral = \stringLiteral("stringLiteral");
	}
	else
	{
		sLiteral = \stringLiteral("literal");
		
		annotations["typ"] = string();
	}
		
	sLiteral = setAnnotations(sLiteral, annotations);
	
	return sLiteral;
}

private Expression normalizeVariableName(Expression variableNode, Config config)
{	
	map[str, value] annotations = getAnnotations(variableNode);
	
	if (!config.respectVariableType)
	{
		annotations["typ"] = string();
	}

	if (v:\variable(name, extraDimensions) := variableNode)
	{
		variableNode = \variable("variable", extraDimensions);
	
		variableNode = setAnnotations(variableNode, annotations);
	}
	
	return variableNode;
}

private Expression normalizeVariableNameWithInitializer(Expression variableNode, Config config)
{
	map[str, value] annotations = getAnnotations(variableNode);
	
	if (!config.respectVariableType)
	{
		annotations["typ"] = string();
	}
	
	if (v:\variable(name, extraDimensions, expressionInitializer) := variableNode)
	{
		variableNode = \variable("variable", extraDimensions, expressionInitializer);
	
		variableNode = setAnnotations(variableNode, annotations);
	}
	
	return variableNode;
}


private Declaration normalizeVariableDeclaration(Declaration variableDeclaration, Config config)
{
	annotations = getAnnotations(variableDeclaration);

	if (!config.respectVariableType)
	{
		annotations["typ"] = null();
	}	

	if (v:\variables(variableType, parameters) := variableDeclaration)
	{		
		variableDeclaration = \variables(config.respectVariableType ? variableType : string(), parameters);
	}
	
	variableDeclaration = setAnnotations(variableDeclaration, annotations);

	return variableDeclaration;
}

//private Statement normalizeReturnStatement(Statement rs, Config config)
//{
//	annotations = getAnnotations(rs);
//	println("returnStatement:<rs>");
//	if (!config.respectVariableType)
//	{
//		annotations["typ"] = null();
//	}	
//
//	if (\return(ex) := rs)
//	{	
//		Expression ex =	normalizeExpression(ex, config);
//		println("ex:<ex>");
//		rs = \return(ex);
//	}
//	
//	rs = setAnnotations(rs, annotations);
//
//	return rs;
//}
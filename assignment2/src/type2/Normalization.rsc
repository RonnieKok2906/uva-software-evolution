module type2::Normalization

import Prelude;
import lang::java::jdt::m3::AST;
import type2::Config;

public node normalizeNode(node subtree, Config config)
{	
	subtree = visit(subtree)
	{
		case n:\method(_, name, parameters, exceptions, impl) => normalizeMethod(n, config)
    	case n:\method(_, name, parameters, exceptions) => normalizeMethod(n, config)
    	case n:\simpleName(_) => normalizeSimpleName(n)
    	case n:\characterLiteral(str charValue) => normalizeCharacterLiteral(n, config)
    	case n:\number(_) => normalizeNumberLiteral(n, config)
    	case n:\booleanLiteral(_) => normalizeBooleanLiteral(n, config)
    	case n:\stringLiteral(_) => normalizeStringLiteral(n, config)
    	case n:\variable(name, extraDimensions) => normalizeVariableName(n, config)
    	case n:\variable(name, extraDimensions, initializerExpression) => normalizeVariableName(n, config)
    	case n:\variables(vType, fragments) => normalizeVariableDeclaration(n, config)
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
	
		methodDeclaration = \method(returnType, "methodIdentifier", parameters, exceptions, impl);
	}

	methodDeclaration = setAnnotations(methodDeclaration, annotations);
	
	return methodDeclaration;
}

private Expression normalizeSimpleName(Expression simpleNameNode)
{	
	map[str, value] annotations = getAnnotations(simpleNameNode);

	return setAnnotations(\simpleName("variable"), annotations);
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

private Expression normalizeStringLiteral(Expression stringLiteral, Config config)
{
	map[str, value] annotations = getAnnotations(stringLiteral);
	
	if (config.respectLiteralType)
	{
		stringLiteral = \stringLiteral("stringLiteral");
	}
	else
	{
		stringLiteral = \stringLiteral("literal");
		
		annotations["typ"] = string();
	}
		
	stringLiteral = setAnnotations(stringLiteral, annotations);
	
	return stringLiteral;
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
	}
	else if (v:\variable(name, extraDimensions, expressionInitializer) := variableNode)
	{
		variableNode = \variable("variable", extraDimensions, expressionInitializer);
	}
	
	variableNode = setAnnotations(variableNode, annotations);
	
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
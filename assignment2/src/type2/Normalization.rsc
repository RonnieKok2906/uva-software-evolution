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
    	//case n:\int() => normalizeIntTypeNode(n, config)
    	//case n:short() => normalizeShortTypeNode(n, config)
    	//case n:long() => normalizeLongTypeNode(n, config)
    	//case n:float() => normalizeFloatTypeNode(n, config)
    	//case n:double() => normalizeDoubleTypeNode(n, config)
    	//case n:char() => normalizeCharTypeNode(n, config)
    	//case n:string() => normalizeStringTypeNode(n, config)
    	//case n:byte() => normalizeByteTypeNode(n, config)
    	//case n:\void() => normalizeVoidTypeNode(n, config)
    	//case n:\boolean() => normalizeBooleanTypeNode(n, config)
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

//private Type normalizeIntTypeNode(Type intNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(intNode);
//	
//	intNode = setAnnotations(Type::\string(), annotations);
//	
//	return intNode;
//}
//
//private Type normalizeShortTypeNode(Type shortNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(shortNode);
//	
//	shortNode = setAnnotations(Type::\string(), annotations);
//
//	return shortNode;
//}
//
//private Type normalizeLongTypeNode(Type longNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(longNode);
//		
//	longNode = setAnnotations(Type::\string(), annotations);
//
//	return longNode;
//}
//
//private Type normalizeFloatTypeNode(Type floatNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(floatNode);
//	
//	floatNode = setAnnotations(Type::\string(), annotations);
//
//	return floatNode;
//}
//
//private Type normalizeDoubleTypeNode(Type doubleNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(doubleNode);
//	
//	doubleNode = setAnnotations(Type::\string(), annotations);
//
//	return doubleNode;
//}
//
//private Type normalizeChartTypeNode(Type charNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(charNode);
//	
//	charNode = setAnnotations(Type::\string(), annotations);
//
//	return charNode;
//}
//
//private Type normalizeStringTypeNode(Type stringNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(stringNode);
//	
//	stringNode = setAnnotations(Type::\string(), annotations);
//
//	return stringNode;
//}
//
//private Type normalizeByteTypeNode(Type byteNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(byteNode);
//	
//	byteNode = setAnnotations(Type::\string(), annotations);
//
//	return byteNode;
//}
//
//private Type normalizeVoidTypeNode(Type voidNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(voidNode);
//	
//	voidNode = setAnnotations(Type::\string(), annotations);
//
//	return voidNode;
//}
//
//private Type normalizeBooleanTypeNode(Type booleanNode, Config config)
//{
//	map[str, value] annotations = getAnnotations(booleanNode);
//	
//	booleanNode = setAnnotations(Type::\string(), annotations);
//
//	return booleanNode;
//}
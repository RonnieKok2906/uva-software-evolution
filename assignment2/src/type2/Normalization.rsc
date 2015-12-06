module type2::Normalization

import Prelude;
import lang::java::jdt::m3::AST;
import type2::Config;

public node normalizeNode(node subtree, Config config)
{	
	subtree = visit(subtree)
	{
		case n:\method(_, name, parameters, exceptions, impl) => normalizeMethodReturnType(setAnnotations(\method(string(), name, parameters, exceptions, impl), getAnnotations(n)), config)
    	case n:\method(_, name, parameters, exceptions) => setAnnotations(method(string(), name, parameters, exceptions), getAnnotations(n), config)
    	case n:\number(_) => normalizeNumberLiteral(n, config)
    	case n:\booleanLiteral(_) => normalizeBooleanLiteral(n, config)
    	case n:\stringLiteral(_) => normalizeStringLiteral(n, config)
    	case n:\variable(name, extraDimensions) => normalizeVariableName(setAnnotations(\variable("variable", extraDimensions), getAnnotations(n)), config)
    	case n:\variable(name, extraDimensions, initializerExpression) => normalizeVariableName(setAnnotations(\variable("variable", extraDimensions, initializerExpression), getAnnotations(n)), config)
    	case n:\int() => normalizeIntTypeNode(n, config)
    	case n:short() => normalizeShortTypeNode(n, config)
    	case n:long() => normalizeLongTypeNode(n, config)
    	case n:float() => normalizeFloatTypeNode(n, config)
    	case n:double() => normalizeDoubleTypeNode(n, config)
    	case n:char() => normalizeCharTypeNode(n, config)
    	case n:string() => normalizeStringTypeNode(n, config)
    	case n:byte() => normalizeByteTypeNode(n, config)
    	case n:\void() => normalizeVoidTypeNode(n, config)
    	case n:\boolean() => normalizeBooleanTypeNode(n, config)
	}
		
	return subtree;
}

private node normalizeMethodReturnType(node method, Config config)
{	
	map[str, value] annotations = getAnnotations(method);

	//println(annotations["typ"]);
	//annotations["typ"] = method(|java+method:///type2TestSource/TestClass4/test1()|,[],string(),[]);
	
	return setAnnotations(method, annotations);
}

private node normalizeNumberLiteral(node numberLiteral, Config config)
{
	map[str, value] annotations = getAnnotations(numberLiteral);
	
	annotations["typ"] = string();
	
	str normalizedString = config.respectLiteralType ? "numberLiteral" : "literal";
	
	return setAnnotations(\stringLiteral(normalizedString), annotations);
}

private node normalizeBooleanLiteral(node booleanLiteral, Config config)
{
	map[str, value] annotations = getAnnotations(booleanLiteral);
	
	annotations["typ"] = string();
	
	str normalizedString = config.respectLiteralType ? "booleanLiteral" : "literal";
	
	return setAnnotations(\stringLiteral("normalizedString"), annotations);
}

private node normalizeStringLiteral(node stringLiteral, Config config)
{
	map[str, value] annotations = getAnnotations(stringLiteral);
	
	annotations["typ"] = string();
	
	str normalizedString = config.respectLiteralType ? "stringLiteral" : "literal";
	
	return setAnnotations(\stringLiteral(normalizedString), annotations);
}

private node normalizeVariableName(node variable, Config config)
{	
	map[str, value] annotations = getAnnotations(variable);
	
	annotations["typ"] = string();
	
	variable = setAnnotations(variable, annotations);

	return variable;
}

private Type normalizeIntTypeNode(Type intNode, Config config)
{
	map[str, value] annotations = getAnnotations(intNode);
	
	intNode = setAnnotations(Type::\string(), annotations);
	
	return intNode;
}

private Type normalizeShortTypeNode(Type shortNode, Config config)
{
	map[str, value] annotations = getAnnotations(shortNode);
	
	shortNode = setAnnotations(Type::\string(), annotations);

	return shortNode;
}

private Type normalizeLongTypeNode(Type longNode, Config config)
{
	map[str, value] annotations = getAnnotations(longNode);
		
	longNode = setAnnotations(Type::\string(), annotations);

	return longNode;
}

private Type normalizeFloatTypeNode(Type floatNode, Config config)
{
	map[str, value] annotations = getAnnotations(floatNode);
	
	floatNode = setAnnotations(Type::\string(), annotations);

	return floatNode;
}

private Type normalizeDoubleTypeNode(Type doubleNode, Config config)
{
	map[str, value] annotations = getAnnotations(doubleNode);
	
	doubleNode = setAnnotations(Type::\string(), annotations);

	return doubleNode;
}

private Type normalizeChartTypeNode(Type charNode, Config config)
{
	map[str, value] annotations = getAnnotations(charNode);
	
	charNode = setAnnotations(Type::\string(), annotations);

	return charNode;
}

private Type normalizeStringTypeNode(Type stringNode, Config config)
{
	map[str, value] annotations = getAnnotations(stringNode);
	
	stringNode = setAnnotations(Type::\string(), annotations);

	return stringNode;
}

private Type normalizeByteTypeNode(Type byteNode, Config config)
{
	map[str, value] annotations = getAnnotations(byteNode);
	
	byteNode = setAnnotations(Type::\string(), annotations);

	return byteNode;
}

private Type normalizeVoidTypeNode(Type voidNode, Config config)
{
	map[str, value] annotations = getAnnotations(voidNode);
	
	voidNode = setAnnotations(Type::\string(), annotations);

	return voidNode;
}

private Type normalizeBooleanTypeNode(Type booleanNode, Config config)
{
	map[str, value] annotations = getAnnotations(booleanNode);
	
	booleanNode = setAnnotations(Type::\string(), annotations);

	return booleanNode;
}
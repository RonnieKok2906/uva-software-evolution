module type3::Config

data Config = config(int minimumNumberOfLines, int numberOfLinesThatCanBeSkipped, bool respectLiteralType, bool respectVariableType, bool respectMethodReturnType);

public Config defaultConfiguration = config(20, 1, false, false, false);
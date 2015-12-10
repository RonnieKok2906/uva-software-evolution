module type2::Config

data Config = config(int numberOfLines, bool respectLiteralType, bool respectVariableType, bool respectMethodReturnType);

public Config defaultConfiguration = config(4, false, false, false);

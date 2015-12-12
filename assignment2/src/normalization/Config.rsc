module normalization::Config

data Config = config(bool respectLiteralType, bool respectVariableType, bool respectMethodReturnType);

public Config defaultConfiguration = config(false, false, false);
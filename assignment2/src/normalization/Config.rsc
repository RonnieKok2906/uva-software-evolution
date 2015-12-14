module normalization::Config

data Config = config(bool respectLiteralType, bool respectVariableType, bool respectMethodReturnType, bool filterSmallerThanBlocks);

public Config defaultConfiguration = config(false, false, false, true);
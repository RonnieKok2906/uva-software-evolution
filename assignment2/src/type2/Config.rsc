module type2::Config

data Config = config(int numberOfLines, bool respectLiteralType);

public Config defaultConfiguration = config(10, false);

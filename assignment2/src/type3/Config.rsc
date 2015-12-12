module type3::Config

data Config = config(int minimumNumberOfLines, int numberOfLinesThatCanBeSkipped);

public Config defaultConfiguration = config(14, 1);
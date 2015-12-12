module type3::Config

data Config = config(int minimumNumberOfLines, int numberOfLinesThatCanBeSkipped);

public Config defaultConfiguration = config(20, 1);
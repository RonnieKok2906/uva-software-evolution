package type3TestSource;

import clonePackage.Util;

public class TestClass4 {
	
	void sumProd1(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod); }}
	
	void sumProd(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod, n); }}
}

package type3TestSource;

import clonePackage.Util;

public class TestClass3 {
	void sumProd(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod); }}
	
		
	//3C. Cloned from original with an if block around the last line. 
	void sumProd3c(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			if (n % 2 == 0) {
			Util.foo(sum, prod);} }}
}

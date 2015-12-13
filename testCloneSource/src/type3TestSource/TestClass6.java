package type3TestSource;

import clonePackage.Util;

public class TestClass6 {
	
	void sumProd1(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod); }}
	
	//3B. Cloned from Original with other interface for foo (see also 3A.)
		void sumProd(int n) {
			double sum = 0.0;//C1
			double prod = 1.0;
			for (int i = 1; i <= n; i++)
				{sum = sum + i;
				prod = prod * i;
				Util.foo(prod); }}
}

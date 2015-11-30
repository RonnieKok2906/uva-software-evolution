package clonePackage.child;

import clonePackage.Util;

public class CloneType3B {
	
	//3B. Cloned from Original with other interface for foo (see also 3A.)
	void sumProd(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(prod); }}
	
}

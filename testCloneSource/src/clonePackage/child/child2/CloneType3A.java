package clonePackage.child.child2;

import clonePackage.Util;

public class CloneType3A {

	//3A. Cloned from original with a different interface for the method foo.
	void sumProd(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod, n); }}
	
}

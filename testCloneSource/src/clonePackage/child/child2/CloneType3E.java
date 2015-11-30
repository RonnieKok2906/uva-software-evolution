package clonePackage.child.child2;

import clonePackage.Util;

public class CloneType3E {
	
	//3E. Cloned from original with line replaced by another line.
	void sumProd(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{ if (i%2 == 0) sum += i;
			prod = prod * i;
			Util.foo(sum, prod); }}
}

package clonePackage2.child;

import clonePackage.Util;

public class CloneType2C {

	//2C. Cloned from original with the double variables assigned by ints.
	void sumProd(int n) {
		double sum = 0;//C1
		double prod = 1;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod); }}
}

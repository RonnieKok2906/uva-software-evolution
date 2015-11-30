package clonePackage2.child;

import clonePackage.Util;

public class CloneType3D {
	
	
	//Cloned from original with removed line.
	void sumProd(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			Util.foo(sum, prod); }}
}

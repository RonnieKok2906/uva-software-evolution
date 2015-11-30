package clonePackage2;

import clonePackage.Util;

public class CloneType2A {
	
	//2A. Cloned from orginal with sum, prod and i replaced by s, p and i
	void sumProd(int n) {
		double s = 0.0;//C1
		double p = 1.0;
		for (int j = 1; j <= n; j++)
			{s = s + j;
			p = p * j;
			Util.foo(s, p); }}

}

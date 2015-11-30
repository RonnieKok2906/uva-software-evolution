package clonePackage.child;

import clonePackage.Util;

public class CloneType2B {
	
	//2B. Clone from Clone 2A with the variables in foo moved around
	void sumProd(int n) {
		double s = 0.0;//C1
		double p = 1.0;
		for (int j = 1; j <= n; j++)
			{s = s + j;
			p = p * j;
			Util.foo(p, s); }}
}

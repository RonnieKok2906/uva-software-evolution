package clonePackage;

public class CloneType1B {
	//Clone from original with more comments
	void sumProd1B(int n) {
		double sum = 0.0;//C1'
		double prod = 1.0;//C
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod); }}
}


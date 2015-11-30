package clonePackage;

public class CloneType1C {
	
	//1C. Cloned from original with brackets on other lines.
	void sumProd(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++) {
			sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod); }}
}

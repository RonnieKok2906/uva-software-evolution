package clonePackage;

public class CloneType2D {
	
	//2D. Cloned from Original, with another computation for the new s and prod
	void sumProd(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + (i*i);
			prod = prod * (i*i);
			Util.foo(sum, prod); }}
}

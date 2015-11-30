package clonePackage;

public class Originaland1Aand3C {
	//http://bl.ocks.org/mbostock/4063530
	
	//Original code fragemnt
	void sumProd(int n) {
	double sum = 0.0;//C1
	double prod = 1.0;
	for (int i = 1; i <= n; i++)
		{sum = sum + i;
		prod = prod * i;
		Util.foo(sum, prod); }}
	
	//1A. Cloned from clone original with more tabs in the for loop.
	void sumProd1a(int n){
	double sum = 0.0;//C1
	double prod = 1.0;
	for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			Util.foo(sum, prod); }}
	
	//3C. Cloned from original with an if block around the last line. 
	void sumProd3c(int n) {
		double sum = 0.0;//C1
		double prod = 1.0;
		for (int i = 1; i <= n; i++)
			{sum = sum + i;
			prod = prod * i;
			if (n % 2 == 0) {
			Util.foo(sum, prod);} }}
	
	
	
	
}

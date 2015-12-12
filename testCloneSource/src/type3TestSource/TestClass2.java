package type3TestSource;

public class TestClass2 {
	
	public double test1()
	{
		double i = 1.0;
		double j = 5.0;
		double i2 = 7.0;
		double i3 = 8.0;
		double i4 = 9.0;
		j = i *j;
		i = test2();
		boolean is = true;
		i = is ? 20000.0 * 20000.0 : 0;
		
		return i;
	}
	
	public double test2()
	{
		double i = 1.0;
		double j = 5.0;

		i = test2();
		
		boolean is = true;
		
		i = is ? 20000.0 * 20000.0 : 0;
		
		return i;
	}
	
	public double test3()
	{
		double i = 1.0;
		double j = 5.0;
		double i2 = 7.0;
		double i3 = 8.0;
		double i4 = 9.0;
		j = i *j;
		i = test2();
		boolean is = true;
		
		return i;
	}
}

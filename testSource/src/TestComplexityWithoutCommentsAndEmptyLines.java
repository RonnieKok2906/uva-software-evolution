



public class TestComplexityWithoutCommentsAndEmptyLines {
	
	//total lines of method: 69
	//simple() : 6 lines
	//moreComplex() : 15 lines
	//complex() : 48
	//pie (simple() : 6.0 / 69.0, moreComplex() : 15.0 / 69.0, complex() : 48.0 / 69.0, untestable() : 0.0 / 69.0) 
	
	//1 line, complexity simple()
	public TestComplexityWithoutCommentsAndEmptyLines() {
		super();
	}

	//5 lines complexity simple()
	public int testSimpleComplexity() {
		int x = 1;
		if (x > 1) {
			System.out.println("x:" + x);
		}
		return 3;
	}

	//15 lines, moreComplex()
	public void testMoreComplexComplexity() {
		boolean x = false;
		boolean y = false;
		boolean z = true;
		if (x || z) {
			for (int i = 0; i < 10; i++) {
			}
		} else if (!y && z) {
			for (int i = 0; i < 10; i++) {
			}
		} else if (!y || !x) {
			for (int i = 0; i < 10; i++) {
			}
		}
		do {
		} while (x);
	}

	//49 lines, complex()
	public void testComplexComplexity(int i) {
		boolean x = true;
		switch (i) {
		case 1:
			return;
		case 2:
			return;
		case 3:
			return;
		case 4:
			return;
		case 5: {
			if (x || !x) {
				break;
			}
		}
		case 6:
			return;
		case 7:
			return;
		case 8:
			return;
		case 9:
			return;
		case 10:
			return;
		case 11:
			return;
		case 12:
			return;
		case 13:
			return;
		case 14:
			return;
		case 15:
			return;
		case 16:
			return;
		case 17:
			return;
		case 18:
			return;
		case 19:
			return;
		case 20:
			return;
		default:
			return;
		}
	}
}


public class TestComplexityWithCommentsAndEmptyLines {

	
	
	
	
	
	
	
	
	
	
	// total lines of code: 79
	// total lines of code in methods: 77
	// complexity: simple() : 10 lines
	// complexity: moreComplex() : 17 lines
	// complexity: complex() : 50
	// compleixty pie (simple() : 10.0 / 77.0, moreComplex() : 17.0 / 77.0, complex() : 50.0
	// / 77.0, untestable() : 0.0 / 77.0)

	//unitSize: low() : 10 lines
	//unitSize: medium() : 67 lines
	//unitSize: high() : 0 lines
	//unitSize: veryHigh() : 0 lines
	// result (low() : 10.0 / 77.0, medium() : 67.0 / 77.0, high() : 0.0 / 77.0, veryHigh() : 0.0 / 77.0)
	
	// 3 lines, complexity simple()
	public TestComplexityWithCommentsAndEmptyLines() {
		super();
	}

	// 7 lines complexity simple()
	public int testSimpleComplexity() {

		int x = 1;
		// Lorem Ipsum
		if (x > 1) {
			// Lorem Ipsum
			System.out.println("x:" + x);
		}

		// Lorem Ipsum
		return 3;
	}

	// Lorem Ipsum

	// 17 lines, moreComplex()
	public void testMoreComplexComplexity() {
		boolean x = false;
		boolean y = false;
		boolean z = true;
		if (x || z) {
			for (int i = 0; i < 10; i++) {
			}
		} else if (!y && z) {
			for (int i = 0; i < 10; i++) {
				/*
				 * Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum
				 * Lorem Ipsum Lorem Ipsum Lorem Ipsum
				 */
			}
		} else if (!y || !x) {
			for (int i = 0; i < 10; i++) {
			}
		}
		do {
			// Lorem Ipsum
		} while (x);
	}

	// 50 lines, complex()
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
				// Lorem Ipsum
			}
		}
		case 6:// Lorem Ipsum
			return;
		case 7:// Lorem Ipsum
			return;
		case 8:// Lorem Ipsum
			return;
		case 9:// Lorem Ipsum
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

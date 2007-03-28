package ParseExpr;
/*
 * Test.java
 *
 * Created on 21 September 2006, 09:41
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
import java.util.Date;
import java.text.SimpleDateFormat;

/**
 * Test a class. Provides tests for simple types. Uses
 * {@link ParseExpr.MyWriter MyWriter} to output to either stdout or a
 * file
 * 
 *  *This module, both source code and documentation, comes with NO WARRANTY.
 * 
 * @author dpawson
 * 
 */
public class Test {
	/**
	 * Test number, incremented for each test
	 * 
	 */
	public  static int testnum = 0;

	/**
	 * Count of failures
	 */
	static int failcount = 0;

	/**
	 * Overall result of the tests
	 */
	static boolean overallResult = true;

	/**
	 * output target
	 */
	static MyWriter output = null;

	/**
	 * Constructor.
	 * 
	 * 
	 * @param application
	 *            the Application under test.
	 * @param destination
	 *            name of output device. Empty string writes to stdout
	 */
	public Test(String application, String destination) {
		output = new MyWriter();
		output.openFile(destination);

		Date now = new Date();
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
		String datetime = df.format(now);
		output.writeln("Testing " + application + ", at " + datetime);
	}
	
	/**
	 * Obtain the number of test failures
	 * @return integer count of failures
	 */
	public int getFailCount(){
		return failcount;
	}
	

	/**
	 * Get the output stream details
	 */
	public String getOutputPath() {
		return output.getOutputStream().getAbsolutePath();
	}

	/**
	 * finish testing, print out the overall result.
	 * 
	 * 
	 */
	public static void stop() {
		output.write("Overall Result = ");
		if (overallResult) {
			output.writeln("Pass");
		} else {
			output.writeln("Fail");
		}
		if (failcount > 0) {
			output.writeln(failcount + " test failures");
		}
		output.quit(); // close down the writer
		System.out.println("\nAll tests completed. " + testnum + " tests run");
                System.out.print("Overall Result: ");
                if (overallResult){
                    System.out.println("Pass");
                }else{
                    System.out.println("Fail");
                }

		

	}

	/**
	 * Display test number and increment
	 * 
	 * @return the next test number in sequence
	 */
	private static String tn() {
		String res = " Test " + testnum + ":: ";
		testnum++;

		if (!output.stream.equals("console")) {
			System.out.print(".");
			if (testnum % 20 == 0)
				System.out.println();
		}
		output.write(res);
		return res;
	}

	/**
	 * 
	 * Assert that two strings are identical in content.
	 * 
	 * @param actual
	 *            string received
	 * @param expected
	 *            string Expected.
	 */
	public static void Assert(String expected, String actual) {
		tn();
		if (expected.equals(actual)) {
			output.write("Pass.");
			String partString = "";
			if (actual.length() > 15)
				partString = actual.substring(0, 15) + "...";
			else
				partString = actual;
			output.writeln("\t\t" + partString);
		} else {
			output.writeln("Fail");
			output.writeln("      Expected:" + expected);
			output.writeln("        Actual:" + actual);
			overallResult = overallResult && false;
			failcount++;
		}

	}

	/**
	 * 
	 * Assert a test
	 * 
	 * @param actual
	 *            int received
	 * @param expected
	 *            int received.
	 */
	public static void Assert(int expected, int actual) {
		tn();
		if (expected == actual) {
			output.write("Pass.");
			output.writeln("\t\t" + actual);
		} else {
			output.writeln("Fail");
			output.writeln("\t\tExpected: " + expected);
			output.writeln("\t\t  Actual: " + actual);
			overallResult = overallResult && false;
			failcount++;
		}
		//System.out.println("Test.Assert: " + testnum);

	}

	/**
	 * Assert test has passed or faile
	 * 
	 * @param expected
	 *            Expected (boolean) from running test
	 * @param actual
	 *            boolean
	 */
	public static void Assert(boolean expected, boolean actual) {
		tn();
		if (expected == actual)
			output.writeln("Pass.\t\t" + true);
		else {
			output.writeln("Fail");
			output.writeln("\t\tExpected: " + expected);
			output.writeln("\t\t  Actual: " + actual);
			overallResult = overallResult && false;
			failcount++;
		}

	}

	/**
	 * Assert that the file contents == the string
	 * 
	 * @param passfail
	 *            the expected result
	 * @param message
	 *            the message to display along with the pass or fail result
	 * 
	 * 
	 */
	public static void Assert(boolean passfail, String message) {
		tn();
		if (passfail)
			output.writeln("Pass against file " + message);
		else {
			output.writeln("\t\tFail. " + message);
			overallResult = overallResult && false;
			failcount++;
		}
	}

	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// Test tst = new Test("mytest", "");
		// Assert("x", "x");
		// Assert(true, true);
		// Assert(modes.ACRONYM, modes.DEFAULT);

	}

}
/**
 * Copyright (C) 2006  Dave Pawson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 **/
package org.dpawson.test;

/*
 * TestTranslate.java
 *
 * Created on 21 September 2006, 09:52
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

import org.dpawson.impl.BrailleEngineFactory;
import org.dpawson.impl.BrailleTable;
import org.dpawson.impl.TextToBraille;
import org.dpawson.util.*;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileOutputStream;

/**
 * Test the text2braille class. Provides a main() and suite of tests for that
 * class. author dpawson. Based on work by MFrodsham. Use this class to test out
 * the entire package. The tests should be exhaustive. If they aren't, we've
 * missed something.
 *
 * @version 1.0.1, {@link org.dpawson.util.Version Version}
 * @author dpawson
 */
public class TestTranslate {
    /**
     * Folder in which test files and expected output is to be found. Structure
     * is <br />
     * <code>NamedDirectory <br />
     *        inputFile.txt<br />
     *        inputFile.txt<br />
     *        ...<br />
     *        results<br />
     *            expectedResults.tdy<br />
     *            expectedResults.tdy<br />
     *            ...<br />
     *            </code> Each input file has a corresponding output file in which expected
     * results are to be found
     */
    static String testFolder = "../test/";
    
    /**
     * Generated braille string
     */
    static String braille = "";
    
    /**
     * Expected test result
     */
    static String expected = "";
    
    /**
     * Test number, incremented for each test
     *
     */
    public static int testnum = 0;
    
    /**
     * Count of failures
     */
    // private static int failcount = 0;
    /**
     * Overall result of the tests
     */
    private static boolean overallResult = true;
    
    /**
     * Constructor Just clear the overall test result
     *
     */
    public TestTranslate() {
        overallResult = true; // set for initial pass
        
    }
    
    /**
     * for DoTest only -  A {@link org.dpawson.impl.TextToBraille TextToBraille }
     */
    static TextToBraille t2b = null;
    
    /**
     * Run a single test
     *
     * @param inFile
     *            input file
     * @param expectedResultsFile
     *            file holding expected result
     * @return true = passed
     */
    public static boolean DoTest(String inFile, String expectedResultsFile) {
        BufferedReader actual = null;
        BufferedReader expected = null;
        System.err.println("File "+ inFile);
        String braille = "";
        try {
            actual = new BufferedReader(new FileReader(inFile));
            expected = new BufferedReader(new FileReader(expectedResultsFile));
        } catch (java.io.FileNotFoundException err) {
            System.err.println("File not found, "+ err.toString());
            System.exit(2);
        }
        String text = "";
        String thisLine = "";
        try {
            
            do {
                text += thisLine;
                thisLine = actual.readLine();
            } while ((thisLine != null) && (!(thisLine.equals(""))));
            actual.close();
        } catch (java.io.IOException err) {
            System.err.println("IO exception on testfile, " + err.toString());
            System.exit(2);
        }
        // Now translate the text
        braille = t2b.Translate(text);
        // expected results
        thisLine = "";
        text = "";
        try {
            do {
                text += thisLine;
                thisLine = expected.readLine();
            } while ((thisLine != null) && (!(thisLine.equals(""))));
            expected.close();
        } catch (java.io.IOException err) {
            System.err.println("IO exception on expected results file, "
                    + err.toString());
            System.exit(2);
            
        }
        
        if (!(braille.equals(text))) {
            FileOutputStream sw = null;
            try {
                sw = new FileOutputStream("dump.txt");
                byte[] bytes = null;
                String s = "\t\tExpected: " + text;
                bytes = s.getBytes();
                sw.write(bytes);
                s = "\n\t\t     Actual: " + braille;
                bytes = s.getBytes();
                sw.write(bytes);
                sw.close();
            } catch (java.io.IOException err) {
                System.err.println("IO exception on expected dump.txt file, "
                        + err.toString());
                System.exit(2);
            }
            
            // @TODO FIXME Are failures being recorded?
            // Test.assert is called, which should count failures.
            overallResult = false;
            return false;
        } else {
            
            return true;
        }
    }
    
    /**
     * main entry point for test harness for text2braille.
     *
     * @param args
     *            input parameters. Currently unused.
     */
    public static void main(String[] args) {
        boolean passed;
        String braille;
        int grade = 2;
        
        BrailleEngineFactory factory = new BrailleEngineFactory();
        BrailleTable table = factory.createBrailleTable("XX");
        TextToBraille t2 = new TextToBraille(table); // t1.getTranslator();
        
        Test test = new Test(t2.getClass().getCanonicalName() + " version "
                + Version.getVersion(), "text2brailleRes.txt");
        
        System.out.println("Running. Results sent to " + test.getOutputPath());
        
        
        // for DoTest only
        t2b = t2;
        
        // Basic method tests.
        String inp = "";
        String ress = ""; // String test result
        int resi = 0; // Integer test result
        
        boolean resb = false;
        // Check Capitalization is off
        t2.setCapitalization(false);
        
        t2.setGrade(2);
        
        // This location is for temporary testing only,
        //resi=table.getRuleNumber("0"," 0 ",2);
        //System.out.println("Rule "+ resi);
        braille = t2.Translate("The quick brown fox jumps over the lazy dog. 1234567890 !\"£$%^&*()_");
        //Test.Assert(";XXXX4",braille); // failing

        System.out.println("["+braille+"]");
        System.out.println("Quitting early");
        System.exit(2);
//        
        // Note. This set of getRuleNumber tests will be different
        // for different languages. Also may change as the rules are modified.
        
        System.out.println("  \t\t Testing started");
        inp = "A ";
        resi = table.getRuleNumber(" ", inp, grade);
        Test.Assert(109, resi);
        
        inp = "2 ";
        resi = table.getRuleNumber(" ", inp, grade);
        resi = table.getRuleNumber(" ", inp, grade);
        Test.Assert(58, resi);
        
        inp = "Z ";// Last rule
        resi = table.getRuleNumber(" ", inp, grade);
        Test.Assert(495, resi);
        
        inp = "31-12-06";
        resb = table.isDate(inp); // 3
        Test.Assert(true, resb);
        
        inp = "01-02-2006";
        resb = table.isDate(inp); // 4
        Test.Assert(true, resb);
        
        resi = table.getDateLength(inp);
        Test.Assert(10, resi);
        
        AnalysisResult ar = new AnalysisResult();
        ar = table.analyse(" ", "RNIB ");
        Test.Assert(Modes.ACRONYM, ar.mode);
        
        ar = new AnalysisResult();
        ar = table.analyse(" ", "CA141711 ");
        Test.Assert(Modes.ACRONYM, ar.mode);
        
        
        inp = "USA ";
        ar = table.analyse("  ", inp);
        Test.Assert(Modes.ACRONYM, ar.mode);
        
        inp = "PE2 6XU ";
        ar = table.analyse(" ", inp);
        Test.Assert(Modes.POSTCODE, ar.mode);
        
        inp = "31-02-2006 ";
        ar = table.analyse(" ", inp);
        Test.Assert(Modes.DATE, ar.mode);
        
        inp = "31/12/2006 ";
        ress = table.doDate(inp, inp.length()).toString();
        Test.Assert("#CA#AB#BJJF", ress);
        
        
        //Valid Roman numerals
        
        
        
        braille = t2.Translate("III");
        Test.Assert(";III",braille);
        
        braille = t2.Translate("iv");
        Test.Assert(";IV",braille);
        
        braille = t2.Translate("XI");
        Test.Assert(";XI",braille);
        
        braille = t2.Translate("XD");
        Test.Assert(";XD",braille);
        
        braille = t2.Translate("XII.");
        Test.Assert(";XII4",braille);
        
        braille = t2.Translate("xii");
        Test.Assert(";XII",braille);
        
        braille = t2.Translate("MM"); // 2000 Roman numeral?
        Test.Assert(";MM",braille);
        
        // Invalid Roman Numerals
        
        
        braille = t2.Translate("MY");
        Test.Assert("MY",braille);
        
        braille = t2.Translate("Cat");
        Test.Assert("CAT",braille);
        
        braille = t2.Translate("Do it");
        Test.Assert("D X",braille);
        
        braille = t2.Translate("XYZ;");
        Test.Assert("XYZ2",braille);   //failing
        
        braille = t2.Translate("I am");
        Test.Assert("I AM",braille);
        
        braille = t2.Translate("Voyage.");
        Test.Assert("VOYAGE4",braille);
        
        braille = t2.Translate("xxxx.");
        Test.Assert(";XXXX4",braille); // failing
        
        
        
        
        braille = t2.Translate("I");  // Check if correct
        Test.Assert("I",braille);
        
        braille = t2.Translate("I am");
        Test.Assert("I AM",braille);
        
        
        
        
        braille = t2.Translate("I'm");
        Test.Assert("I'M",braille);
        
        t2.setCapitalization(false);
        
        
        
        for (grade = 1; grade < 3; grade++) {
            t2.setGrade(grade);
            
            braille = t2.Translate("0845 7585691"); // 10
            Test.Assert("#JHDE#GEHEFIA", braille);
            
            braille = t2.Translate("ITEM(S)");
            Test.Assert("ITEM7S7", braille);
            
            braille = t2.Translate("............");
            Test.Assert("111111111111", braille);
            
            braille = t2.Translate("**");
            Test.Assert("99 99", braille);
            
            braille = t2.Translate("7008/0");
            Test.Assert("#GJJH_/#J", braille);
            
            braille = t2.Translate("VAT.]");
            Test.Assert(";VAT47'", braille);
            
            braille = t2.Translate("CA141711");
            Test.Assert(";CA#ADAGAA", braille);
            
            braille = t2.Translate("USA");
            Test.Assert(";USA", braille);
            
            braille = t2.Translate("HP12 3SH");
            Test.Assert(";HP#AB #C;SH", braille);
            
            braille = t2.Translate("01/02/06");
            Test.Assert("#JA#JB#JF", braille);
            
            braille = t2.Translate("01/02/2000");
            Test.Assert("#JA#JB#BJJJ", braille);
            
            braille = t2.Translate("Hr");
            Test.Assert(";HR", braille);
            
            braille = t2.Translate("PRE-ADVICE");
            Test.Assert("PRE-ADVICE", braille);
            
            braille = t2.Translate("N.B.");
            Test.Assert("N4B4", braille);
            
            braille = t2.Translate("-A/C");
            Test.Assert("-;A_/;C", braille);
            
            braille = t2.Translate("FY1 1EL");
            Test.Assert(";FY#A #A;EL", braille);
            
            braille = t2.Translate("BD1 2AL");
            Test.Assert(";BD#A #B;AL", braille);
            
            braille = t2.Translate("a.m.");
            Test.Assert("A4M4", braille);
            
            braille = t2.Translate("IBAN");
            Test.Assert(";IBAN", braille);
            
            braille = t2.Translate("BIC");
            Test.Assert(";BIC", braille);
            
            braille = t2.Translate("CR");
            Test.Assert("CR", braille);
            
            braille = t2.Translate("Cr");
            Test.Assert("CR", braille);
            
            braille = t2.Translate("DB");
            Test.Assert("DB", braille);
            
            braille = t2.Translate("Db");
            Test.Assert("DB", braille);
            
            braille = t2.Translate("XX   ");
            Test.Assert(";XX   ", braille);
            
        } // end of for loop over grades 1..2
        
        
        t2.setGrade(2);
        t2.setCapitalization(false);
        
        
        
        System.err.println(Test.testnum + " text tests run");
        System.err.println("Now running File based tests from "+testFolder);
        
        passed = DoTest(testFolder + "Para3.txt", testFolder
                + "results/Para3.tdy");
        Test.Assert(passed, "Para3.tdy");
        
        passed = DoTest(testFolder + "Para4.txt", testFolder
                + "results/Para4.tdy");
        Test.Assert(passed, "Para4.tdy");
        
        passed = DoTest(testFolder + "Para5.txt", testFolder
                + "results/Para5.tdy");
        Test.Assert(passed, "Para5.tdy");
        
        passed = DoTest(testFolder + "Para6.txt", testFolder
                + "results/Para6.tdy");
        Test.Assert(passed, "Para6.tdy");
        
        passed = DoTest(testFolder + "Para7.txt", testFolder
                + "results/Para7.tdy");
        Test.Assert(passed, "Para7.tdy");
        
        passed = DoTest(testFolder + "Para8.txt", testFolder
                + "results/Para8.tdy");
        Test.Assert(passed, "Para8.tdy");
        
        passed = DoTest(testFolder + "Para9.txt", testFolder
                + "results/Para9.tdy");
        Test.Assert(passed, "Para9.tdy");
        
        passed = DoTest(testFolder + "Para10.txt", testFolder
                + "results/Para10.tdy");
        Test.Assert(passed, "Para10.tdy");
        
        passed = DoTest(testFolder + "Para11.txt", testFolder
                + "results/Para11.tdy");
        Test.Assert(passed, "Para11.tdy");
        
        passed = DoTest(testFolder + "Para12.txt", testFolder
                + "results/Para12.tdy");
        Test.Assert(passed, "Para12.tdy");
        
        passed = DoTest(testFolder + "Para13.txt", testFolder
                + "results/Para13.tdy");
        Test.Assert(passed, "Para13.tdy");
        
        passed = DoTest(testFolder + "Para14.txt", testFolder
                + "results/Para14.tdy");
        Test.Assert(passed, "Para14.tdy");
        
        passed = DoTest(testFolder + "Para15.txt", testFolder
                + "results/Para15.tdy");
        Test.Assert(passed, "Para15.tdy");
        
        passed = DoTest(testFolder + "Para16.txt", testFolder
                + "results/Para16.tdy");
        Test.Assert(passed, "Para16.tdy");
        
        passed = DoTest(testFolder + "Para17.txt", testFolder
                + "results/Para17.tdy");
        Test.Assert(passed, "Para17.tdy");
        
        passed = DoTest(testFolder + "Para18.txt", testFolder
                + "results/Para18.tdy");
        Test.Assert(passed, "Para18.tdy");
        
        passed = DoTest(testFolder + "Para19.txt", testFolder
                + "results/Para19.tdy");
        Test.Assert(passed, "Para19.tdy");
        
        passed = DoTest(testFolder + "Para20.txt", testFolder
                + "results/Para20.tdy");
        Test.Assert(passed, "Para20.tdy");
        
        passed = DoTest(testFolder + "Para21.txt", testFolder
                + "results/Para21.tdy");
        Test.Assert(passed, "Para21.tdy");
        
        passed = DoTest(testFolder + "Para22.txt", testFolder
                + "results/Para22.tdy");
        Test.Assert(passed, "Para22.tdy");
        
        passed = DoTest(testFolder + "Lesson23.txt", testFolder
                + "results/Lesson23.tdy");
        Test.Assert(passed, "Lesson23.tdy");
        
        passed = DoTest(testFolder + "Lesson24.txt", testFolder
                + "results/Lesson24.tdy");
        Test.Assert(passed, "Lesson24.tdy");
        
        passed = DoTest(testFolder + "Lesson25.txt", testFolder
                + "results/Lesson25.tdy");
        Test.Assert(passed, "Lesson25.tdy");
        
        // Miscellaneous simple tests
        
        // Post code
        braille = t2.Translate("SG6 1RE");
        Test.Assert(";SG#F #A;RE", braille);
        
        // Acronyms (and exceptions)
        braille = t2.Translate("THE FZR750 WAS A CLASSIC.");
        Test.Assert("! ;FZR#GEJ 0 A CLASSIC4", braille);
        braille = t2.Translate("CR");
        Test.Assert("CR", braille);
        braille = t2.Translate("Cr");
        Test.Assert("CR", braille);
        braille = t2.Translate("HSBC plc");
        Test.Assert(";HSBC ;PLC", braille);
        
        // Single letters
        braille = t2
                .Translate("B C D E F G H J K L M N O P Q R S T U V W X Y Z");
        Test
                .Assert(
                ";B ;C ;D ;E ;F ;G ;H ;J ;K ;L ;M ;N ;O ;P ;Q ;R ;S ;T ;U ;V ;W ;X ;Y ;Z",
                braille);
        
        // Capitalisation tests
        
        t2.setCapitalization(true);
        braille = t2.Translate("The Cat Sat On The Mat");
        Test.Assert(",! ,CAT ,SAT ,ON ,! ,MAT", braille);
        
        braille = t2.Translate("THE CAT SAT ON THE MAT");
        Test.Assert(",,! ,,CAT ,,SAT ,,ON ,,! ,,MAT", braille);
        
       
        Test.stop();
        
    }
}

/**
 * Copyright (C) 2006 Dave Pawson
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 51
 * Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

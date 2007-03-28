package org.dpawson.impl;

/*
 * TextToBraille.java
 *
 * Created on 21 September 2006, 10:15
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */


import org.dpawson.impl.BrailleTable;
import org.dpawson.util.*;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileOutputStream;
import java.io.File;
import java.io.IOException;


import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * Braille Translator. Assumptions: That prepended and appended whitespace is
 * treated outside of this module. That embedded whitespace will be normalized
 * (between words). If this is not wanted, use the calling application.
 *
 * @author dpawson
 * @version 1.0.1
 * @see org.dpawson.util.Version
 */
public class TextToBraille {
    
    /**
     * Version of the program
     */
    public static String version = Version.getVersion();
    
    
    /**
     * BrailleTable object, to access the locale specific methods
     **/
    //BrailleTable brailleTable=null;
    public BrailleTable table =null;
    
    
    /**
     * Array of rules used for translation, {@link org.dpawson.impl.Rule Rule}
     *
     *
     */
    static Rule rules[] = null;
    
    /**
     * Total count of rules found in rules file
     *
     * @see org.dpawson.impl.BrailleTable#rulecount
     */
    int ruleCount = 0; // count of rules
    
    /**
     * Required grade of braille, 1 or 2
     */
    int Grade = 1;
    
    /**
     * Debug - Higher value, more output
     */
    private int debug = 1;
    
    /**
     * Optimisation table, content form is 'string' : int Indexes into the
     * rules table for faster access.
     *Now moved to brailletable
     */
    //HashMap<String, Integer> optimisationTable = new HashMap<String, Integer>();
    
    /**
     * Text prior to the  current point.
     *
     */
    //static String leftContext;
    
    /**
     * Set true if Capitalisation is being used. Otherwise false.
     */
    static boolean Capitalization = false;
    
    
    
    /**
     * Length of a token
     */
    // static int _tokenLength = 0;
    /**
     * Output stream to which content is written, {@link org.dpawson.util.MyWriter MyWriter}
     */
    private FileOutputStream output;
    
    /**
     * Modes of operation, {@linkplain org.dpawson.util.Modes Modes}
     *
     *
     */
    static Modes mode = null;
    
    
    
    
    
    /**
     * Constructor 1 ,  Compile regex's
     */
    public TextToBraille() {
        
        
    }
    
    /**
     *Constructor using an existing {@link org.dpawson.impl.BrailleTable BrailleTable}
     *@param tbl is the {@link org.dpawson.impl.BrailleTable BrailleTable } to use
     **/
    public TextToBraille(BrailleTable tbl){
        rules = tbl.rules;
        table = tbl; // to get hold of the locale specific methods.
    }
    
    
    /**
     *Set the grade, only valid for 1 or 2, otherwise null action
     **/
    public void setGrade(int grade){
        if (grade >=1 && grade <=2)
            Grade=grade;
    }
    
    /**
     * Set capitalization, true or false where true sets it on.
     **/
    public void setCapitalization(boolean on){
        Capitalization = on;
    }
    
    /**
     *Determine if Capitalization is on or off
     **/
    public boolean getCapitalization(){
        return this.Capitalization;
    }
    
    
    
    
    /**
     * Load up  {@link #rules rules} from the input file
     *
     * @param filename
     *                of rules file.
     * @param grade
     *                (1 or 2, sets default contraction)
     */
    public void text2brailleInit(String filename, int grade) {
        System.out.println("TextToBraille.text2brailleInit");
        // based on init in cs file
        if (grade == 1)
            this.Grade = 1;
        else if (grade == 2)
            this.Grade = 2;
        else {
            System.err.println("Invalid grade value " + grade + ". Quitting");
            System.exit(2);
        }
        Capitalization = false; // defaults to false
        //@TODO
        
        /**
         * Set up faster access to braille table.
         * Now held in the braille Table
         */
        //optimisationTable = new HashMap<String, Integer>();
        
//        int n = 0; // rule count
//        int i = 0;
//        int j = 0;
//        String line = null;
//        String[] fields;
//
        // Count the rules whilst reading in
//        try {
//
//            BufferedReader reader = new BufferedReader(new FileReader(filename));
//            while ((line = reader.readLine()) != null) {
//                if (line.length() > 0)
//                    if (line.charAt(0) != '/') {
//                    // System.err.println("Rule "+n);
//                    n++;
//                    }
//            }
//            reader.close();
//            if (debug > 5)
//                pr(Integer.toString(n) + " rules read in");
//        } catch (java.io.IOException e) {
//            System.err.println("**** IO Error on braille table  file "
//                    + filename + "\n Quitting\n" + e.toString());
//            System.exit(2);
//        }
        
        // There are n rules. Now read them in.
//        rules = new Rule[n];
//        this.ruleCount = n; // set count of rules
//        String key = "";
//        try {
//            BufferedReader reader = new BufferedReader(new FileReader(filename));
//            i = 0;
//
//            // Read in all rules file lines except comments, assign to rules
//
//            while ((line = reader.readLine()) != null) {
//                if (line.length() > 0) // Non-empty line
//                    if (line.charAt(0) != '/') {
//                    fields = line.split("\t");
//                    rules[i] = new Rule();
//                    rules[i].LEFTCONTEXT = fields[0];
//                    rules[i].INPUT = fields[1].split("\\|")[0];
//                    rules[i].RIGHTCONTEXT = fields[2];
//                    rules[i].OUTPUT = fields[3];
//                    rules[i].SHIFT = Integer.parseInt(fields[4]);
//
//                    j = 0;
//                    if (fields[1].charAt(0) == '\\') {
//                        j = 1;
//                    }
//                    key = fields[1].substring(j, j + 1);
//                    if (!brailleTable.optimisationTable.containsKey(key)) // @FIXME
//                        // mf
//                        // Contains(key))
//                    {
//                        optimisationTable.put(key, i);
//                        // if (debug == 1) System.out.println(" init:
//                        // key =
//                        // "+ key);
//                    }
//
//                    i++;
//                    }
//            }
//            reader.close();
//        } catch (java.io.IOException e) {
//            System.out.println("**** IO Error on braille table " + filename
//                    + " file. Quitting");
//            System.exit(2);
//        }
    }// end of constructor
    
    
    
    
    
    /**
     * Default translate the text to braille, assumes grade II
     * simply calls {@link #Translate(String, int)}
     * @param text
     *                to translate
     * @return translated string
     */
    public String Translate(String text) {
        
        return Translate(text, this.Grade);
    }
    
    
    
    
    
    
    
    /**
     * get token length, abstracted from GetMode() code.
     * @param src - Input string containing token
     * @param mode - current {@link org.dpawson.util.Modes Modes}
     * @return integer length of this token
     */
//    public int getTokenLength(String src, Modes mode) {
//        Matcher m;
//        String t;
//        Pattern patt;
//        int res = 0;
//
//        t = src.toUpperCase();
//
//        // if (mode == Modes.POSTCODE)
//        if (mode == Modes.POSTCODE) {
//            // Postcode?
//            // patt = Pattern.compile(text2braille.postcodeRE);
//            patt = table.getPostCodeREPatt();
//            m = patt.matcher(leftContext + t);
//            if (m.find()) {
//                res = m.group(1).length(); // .Length;
//            }
//
//        } else if (mode == Modes.DATE) {
//
//            // Date?
//            patt = Pattern.compile(table.dateRE);
//            m = patt.matcher(t);
//            if (m.find()) {
//                res = m.group().length();
//            }
//        } else { // Unknown type - use DEFAULT
//            return src.length();
//        }
//        return res;
//    }
    
    /**
     *Process an acronym through to braille.
     * @param leftContext - left Context on entry
     * @param src - source string to process
     * @param len - length of acronym found
     * @return contracted braille
     **/
    //@TODO Is this language dependent?
    // If so, move to ENBrailleTable
    String doAcronym(String leftContext, String src, int len) {
        int shift=0;
        int ruleNumber=0;
        int j=0;
        
        String prefix=leftContext;
        String text=src;
        //Matcher m;
        StringBuilder sb;
        sb = new StringBuilder();
        
        
        // Set Grade to 1 for acronym processing
        int gradeStore = Grade;
        Grade = 1;
        
        
        while (j < len) {
            ruleNumber =   this.table.getRuleNumber(prefix, text, Grade );
            sb.append(rules[ruleNumber].OUTPUT);
            shift = rules[ruleNumber].SHIFT;
            prefix = prefix.substring(1,2) + text.substring(shift - 1, shift);
            text = text.substring(shift);
            j += shift;
        }
        // Restore grade
        Grade = gradeStore;
        return sb.toString();
    }
    
    
    /**
     *Process a String through to braille, using grade 1 - that is, simple translation.
     * @param leftContext - left Context on entry
     * @param src - source string to process
     * @param len - Character count to process
     * @return contracted braille
     * This is not deemed language dependent
     **/
    
    String prGrade1(String leftContext, String src, int len) {
        //System.out.println("prGrade1 on "+ src);
        int shift=0;
        int ruleNumber=0;
        int j=0;
        
        String prefix=leftContext;
        String text=src;
        //Matcher m;
        StringBuilder sb;
        sb = new StringBuilder();
        
        
        // Set Grade to 1 for  processing
        int gradeStore = Grade;
        Grade = 1;
        
        
        while (j < len) {
            ruleNumber =   this.table.getRuleNumber(prefix, text, Grade );
            sb.append(rules[ruleNumber].OUTPUT);
            shift = rules[ruleNumber].SHIFT;
            prefix = prefix.substring(1,2) + text.substring(shift - 1, shift);
            text = text.substring(shift);
            j += shift;
        }
        // Restore grade
        Grade = gradeStore;
        return sb.toString();
    }
    
    
    
    
    /**
     * Convert a post code to braille
     * @param s - input text to process
     * @param len - length of postCode expression
     * @return -braille Equivalent
     *
     */
    String DoPostCode(String s, int len) {
        int i = 0;
        StringBuilder sb;
        boolean digit;
        digit = false;
        sb = new StringBuilder();
        sb.append(';');
        for (i = 0; i < len; i++) {
            
            switch (s.charAt(i)) {
                case ' ':
                    sb.append(' ');
                    digit = false;
                    break;
                case '0':
                    if (!digit)
                        sb.append('#');
                    sb.append('J');
                    digit = true;
                    break;
                case '1':
                    if (!digit)
                        sb.append('#');
                    sb.append('A');
                    digit = true;
                    break;
                case '2':
                    if (!digit)
                        sb.append('#');
                    sb.append('B');
                    digit = true;
                    break;
                case '3':
                    if (!digit)
                        sb.append('#');
                    sb.append('C');
                    digit = true;
                    break;
                case '4':
                    if (!digit)
                        sb.append('#');
                    sb.append('D');
                    digit = true;
                    break;
                case '5':
                    if (!digit)
                        sb.append('#');
                    sb.append('E');
                    digit = true;
                    break;
                case '6':
                    if (!digit)
                        sb.append('#');
                    sb.append('F');
                    digit = true;
                    break;
                case '7':
                    if (!digit)
                        sb.append('#');
                    sb.append('G');
                    digit = true;
                    break;
                case '8':
                    if (!digit)
                        sb.append('#');
                    sb.append('H');
                    digit = true;
                    break;
                case '9':
                    if (!digit)
                        sb.append('#');
                    sb.append('I');
                    digit = true;
                    break;
                case 'A':
                case 'B':
                case 'C':
                case 'D':
                case 'E':
                case 'F':
                case 'G':
                case 'H':
                case 'I':
                case 'J':
                case 'K':
                case 'L':
                case 'M':
                case 'N':
                case 'O':
                case 'P':
                case 'Q':
                case 'R':
                case 'S':
                case 'T':
                case 'U':
                case 'V':
                case 'W':
                case 'X':
                case 'Y':
                case 'Z':
                    if (digit)
                        sb.append(';');
                    sb.append(s.charAt(i));
                    digit = false;
                    break;
            }
        }
        return sb.toString();
    }
    
    /**
     * Translate a string, translation accounts for leftContext as a prefix
     *
     *
     * @param text
     *                Input text to translate
     * @param grade
     *                Grade wanted (1 or 2)
     * @return translated string
     */
    public String Translate(String text, int grade) {
        //System.out.println("TextToBraille.Translate(string, int ): called with ["+  text+"]");
        int i = 0, j = 0, n = 0, shift = 0;
        String src = text + " ";
        StringBuilder braille = new StringBuilder();
        Matcher m;
        this.Grade = grade; //Is this used?
        String leftContext = "  ";
        
        // Must leave a space on the end of the sought expression, for the rightContext match
        // So iterate over src.length -1
        n = src.length() - 1;
        while (j < n) {
            //Find out mode and length of match
            AnalysisResult analysis = this.table.analyse(leftContext,src);
            //System.out.println(" mode: "+analysis.mode);
            //If PostCode:
            if (analysis.mode == Modes.POSTCODE) {
                // append post code to output
                braille.append(DoPostCode(src, analysis.length));
                
                // Move on past the postCode
                leftContext = leftContext.substring(1,2) +
                        src.substring(analysis.length - 1, analysis.length);
                src = src.substring(analysis.length); // remainder of src
                j += analysis.length;
            }else if (analysis.mode == Modes.ROMANNUMERAL) {
                // Insert letter sign into output
                braille.append( prGrade1(leftContext, src, analysis.length ));
                leftContext = leftContext.substring(1,2) + src.substring(0,1);
                src = src.substring(analysis.length);
                j += analysis.length;
                
                
            } else if (analysis.mode == Modes.ACRONYM) {
                // Insert letter sign into output stream at start of acronym - if not already present
                //braille.append( ";"+doAcronym(leftContext, src, analysis.length ));
                String tmp = doAcronym(leftContext, src, analysis.length );
                if (!(tmp.charAt(0) == ';'))
                    braille.append( ";"+tmp);
                else
                    braille.append(tmp);
                
                // move on past the acronym
                leftContext = leftContext.substring(1,2)+ src.substring(0, 1); // first char
                src = src.substring(analysis.length);
                j += analysis.length;
                
                
            } else if (analysis.mode == Modes.DATE) {
                braille.append(this.table.doDate(src, analysis.length));
                
                // Move on past the date
                leftContext = leftContext.substring(1,2) +
                        src.substring(analysis.length - 1, analysis.length);
                src = src.substring(analysis.length);
                j += analysis.length;
                
                
            } else if (analysis.mode == Modes.DEFAULT) {
                // Find a matching rule
                i = table.getRuleNumber( leftContext, src, this.Grade);
                if (i > table.getRulesTotal()){
                    System.err.println("Translate: Overrun, Quitting, ");
                    System.exit(2);
                }
                //System.err.println("TextToBraille.Translate: rule # "+ i+". inp:[{"+ leftContext+"}"+src+"]");
                
                // Insert capital sign into output stream as required
                if (Capitalization) {
                    Pattern p = Pattern.compile("\\s$");
                    m = p.matcher(leftContext);
                    if (m.find()){
                        p = Pattern.compile("^[A-Z][a-z]+\\s");
                        m=p.matcher(src);
                        if (m.find()){
                            braille.append(",");
                        }else {
                            p = Pattern.compile("\\s$");
                            m = p.matcher(src);
                            if (m.find()){
                                braille.append(",,");
                            }
                        }
                        
                    }
                }
                // add latest part to braille
                braille.append(rules[i].OUTPUT);
                //System.out.println("Adding ["+rules[i].OUTPUT+"] from rule "+i);
                shift = rules[i].SHIFT;
                leftContext = leftContext.substring(1,2) + src.substring(shift - 1,shift); ///WTF?
                
                src = src.substring(shift);
                j += shift;
            }
        }
        return braille.toString();
    }
    
    /**
     * Root method for application - Process the input file using braille table
     * and grade, to produce the output file
     *
     * @param t2b
     *                the translator
     * @param infile
     *                the input text file to process
     * @param outfile
     *                the resulting tranformed text file for output
     */
    public void prFile(TextToBraille t2b, String infile, File outfile,
            String braillefile, int grade) {
        String line = "";
        String[] fields = new String[2];
        String op = "";
        
        openFile(outfile);
        t2b.text2brailleInit(braillefile, grade);
        try {
            BufferedReader reader = new BufferedReader(new FileReader(infile));
            
            while ((line = reader.readLine()) != null) {
                fields = line.split(" ");
                op = t2b.Translate(fields[0]);
                if (op.equals(fields[1])) {
                    writeln(fields[0] + " " + fields[1]);
                    
                } else {
                    writeln("***" + fields[0] + " = " + op);
                }
            }
            
            reader.close();
        } catch (java.io.IOException e) {
            System.out
                    .println("**** IO Error on braille table  file. Quitting");
            System.exit(2);
        }
        
    }
    
    /**
     * Open the output file for writing
     *
     * @param opFile ,
     *                File for writing. "" implies system.out
     */
    private void openFile(File opFile) {
        // File opFile = new File(fName);
        
        if (opFile == null || opFile.getName().equals("")) {
            System.err.println("\nOpening console for output\n");
        } else {
            // Open the file
            try {
                output = new FileOutputStream(opFile);
            } catch (IOException e) {
                System.err.println("Error opening file" + e);
            }
        }
    }
    
    /*
     * write to the output stream
     *
     */
    public void write(String s) {
        if (output == null) {
            System.out.print(s);
            
        } else {
            byte[] bytes = null;
            bytes = s.getBytes();
            try {
                output.write(bytes);
                output.flush();
            } catch (java.io.IOException e) {
                System.err.println("text2braille: IO exception");
                System.exit(1);
            }
        }
    }
    
    /**
     * Write a string to the output stream
     *
     * @param text
     *                to write
     *
     */
    public void writeln(String text) {
        if (output == null) {
            System.out.print(text);
            
        } else {
            String str = "\n" + text;
            byte[] bytes = null;
            bytes = str.getBytes();
            try {
                output.write(bytes);
                output.flush();
            } catch (java.io.IOException e) {
                System.err.println("text2braille: IO exception");
                System.exit(1);
            }
            
        }
    }
    
    /*
     * Standard Entry point: Calls doMain for action. @param argv
     *
     * @see <a href="#doMain">doMain</a>
     */
    
    /**
     * Actual main method.
     *
     * @param argv
     *                Primary input command line arguments
     */
    public static void main(String[] argv) {
        // the real work is delegated to another routine so that it can be used
        // in a subclass
        // text2braille ttb = new text2braille();
        (new TextToBraille()).doMain(argv, new org.dpawson.impl.TextToBraille(),
                "Text to braille");
        
    }
    
    /**
     * Resolves command line parameters and calls the application
     *
     * @param args
     *                Command line arguments
     * @param app
     *                class to be constructed
     * @param name
     *                Application name <a name='doMain' />
     */
    
    protected void doMain(String args[], TextToBraille app, String name) {
        
        File outputFile = null;
        String outputFileName = null;
        String rulesFileName = null;
        String inputFileName = null;
        // Check the command-line arguments.
        
        try {
            int i = 0;
            while (true) {
                if (i >= args.length)
                    break;
                if (debug > 9)
                    System.err.println("i: " + i + args.length + " args[i]="
                            + args[i]);
                
                if (args[i].charAt(0) == '-') {
                    if (args[i].equals("-t")) {
                        System.err.println(Version.getProductName());
                        i++;
                        
                    } else if (args[i].equals("-b")) {
                        i++;
                        if (args.length < i + 1)
                            badUsage(name, "No braille Rules  file Specified");
                        rulesFileName = args[i++];
                        if (debug > 5)
                            System.err.println("Rules file: " + rulesFileName);
                        
                    } else if (args[i].equals("-i")) {
                        i++;
                        if (args.length < i + 1)
                            badUsage(name, "No input  file Specified");
                        inputFileName = args[i++];
                        if (debug > 5)
                            System.err.println("input file: " + inputFileName);
                        
                    } else if (args[i].equals("-g")) {
                        i++;
                        if (args.length < i + 1)
                            badUsage(name, "No braille grade specified");
                        try {
                            this.Grade = Integer.parseInt(args[i++]);
                        } catch (java.lang.NumberFormatException err) {
                            System.err
                                    .println("Invalid grade, should be 1 or 2. Quitting");
                            System.exit(2);
                        }
                        if (debug > 5)
                            System.err.println("Grade =: " + this.Grade);
                    }
                    
                    else if (args[i].equals("-o")) {
                        i++;
                        if (args.length < i + 1)
                            badUsage(name, "No output file name");
                        outputFileName = args[i++];
                        if (debug > 5)
                            System.err.println("op file: " + outputFileName);
                        
                    } else
                        badUsage(name, "Unknown option " + args[i]);
                } else
                    break;
            } // end while
            if (outputFileName != null) {
                outputFile = new File(outputFileName);
                if (outputFile.isDirectory()) {
                    quit("Output is a directory");
                }
            }
        } catch (Exception err2) {
            err2.printStackTrace();
        }
        // Check for files available: input, property and output
        if (inputFileName == null)
            badUsage(name, "No Input File available; Quitting");
        if (outputFileName == null)
            badUsage(name, "No Output File available; Quitting");
        if (rulesFileName == null)
            badUsage(name, "No rules File available; Quitting");
        if (this.Grade == 0 || this.Grade < 1 || this.Grade > 2)
            badUsage(name, "Grade must be specified, 0 < grade < 3; Quitting");
        
        if (debug > 0)
            System.out.println("Running at debug level " + debug);
        if (this.debug > 2) {
            System.err.println("params: Producing " + outputFileName + " from "
                    + inputFileName + ". Using " + rulesFileName
                    + " at braille grade " + this.Grade);
        }
        if (inputFileName == null || inputFileName == "") {
            System.err.println("Invalid input file, Quitting");
            System.exit(2);
        }
        
        prFile(app, inputFileName, outputFile, rulesFileName, this.Grade);
        
        // end the root calls
        
        System.exit(0);
    } // end of domain.
    
    /**
     * Exit with a message
     *
     * @param message
     *                Message to be output prior to quitting.
     */
    protected static void quit(String message) {
        System.err.println(message);
        System.exit(2);
    }
    
    /**
     * Output the command line help.
     *
     * @param name
     *                option in errror
     * @param message
     *                associated message
     *
     */
    protected void badUsage(String name, String message) {
        System.err.println(message);
        System.err.println(Version.getProductName());
        System.out.println("Version" + Version.getVersion());
        System.err.println("Usage: " + name + " [options] {param=value}...");
        System.err.println("Options: ");
        System.err.println("  -b filename     Braille Table file  ");
        System.err.println("  -o filename     Send output to named file  ");
        System.err
                .println("  -i filename     Take input text input from named file  ");
        System.err.println("  -g grade     Grade of braille required, 1 or 2 ");
        System.err.println("  -t              Display version information ");
        System.err.println("  -?              Display this message ");
        System.exit(2);
    }
    
    /**
     * print a string s
     * @param s - String to print
     *
     */
    private void pr(String s) {
        System.out.println(" " + s);
        
    }
    
}// end of text2braille class

/**
 * Copyright (C) 2006  Dave Pawson. Based on code by Mark Frodsham
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

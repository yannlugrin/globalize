/*
 * ENBrailleTable.java
 *
 * Created on 18 September 2006, 13:57
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.impl;

//import java.io.BufferedReader;
import java.io.File;
//import java.io.FileReader;
import java.util.ArrayList;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.dpawson.util.Modes;
import org.dpawson.util.AnalysisResult;

/**
 * Implementation of en-UK braille table
 *
 * @author dpawson
 */
public class ENBrailleTable extends BrailleTable {
    
    /**
     * Post code RE
     */
    protected static final String postcodeRE = "^([A-Z][A-Z]?[0-9][0-9]? [0-9][A-Z][A-Z])";
    
    /**
     * Compiled pattern.
     */
    protected Pattern postCodeREpatt = null;
    
    /**
     * Obtain the compiled Pattern for a postCode
     *
     * @return compiled pattern
     */
    protected Pattern getPostCodeREPatt() {
        return Pattern.compile(postcodeRE);
    }
    
    /**
     * Valid acronym list for lang en
     */
    private static final String _acronyms = "GB|PO|BIC|IBAN|RNIB|USA|VAT";
    
    /**
     * regex used for acronyms
     */
    private static final String acronymRE = "^[^\\w'](([BCDFGHJKLMNPQRSTVWXZ][BCDFGHJKLMNPQRSTVWXZ0-9]+)|"
            + _acronyms + ")\\W";
    
    /**
     * Compiled version of acronym Regex pattern
     *
     */
    protected Pattern acronymREpatt = null;
    
    /**
     * Obtain compiled pattern for an acronym
     *
     * @return compiled pattern for an acronym
     */
    protected Pattern getAcronymREPatt() {
        return this.acronymREpatt;
    }
    
    
    /**
     * Second attempt at finding acronyms, of the form ABCD123
     */
    private static final String acronym2RE = "^[^\\w']([A-Z]+[0-9]+)\\W";
    
    /**
     * Compiled Pattern for second RE use.
     */
    protected Pattern acronym2REpatt = null;
    
    /**
     * Obtain compiled Acronym pattern (2)
     *
     * @return compiled Pattern
     */
    protected Pattern getAcronym2REpatt() {
        return this.acronym2REpatt;
        
    }
    
    /**
     * Regex for date, en
     */
    protected  final String dateRE = "^\\d{1,2}[\\.\\-/]\\d{1,2}[\\.\\-/]\\d{2,4}";
    
    /**
     * compiled Pattern for date RE if needed
     */
    protected static Pattern dateREpatt = null;
    
    /**
     * Obtain compiled Pattern for a date
     *
     * @return compiled Pattern
     */
    protected Pattern getDateREpatt() {
        return Pattern.compile(dateRE);
    }
    
    
    /**
     * Exceptions to acronyms. Pipe separated list of 'words' which are
     * definately not to be marked as acronyms. Checked prior to regex'ing
     * agains the acronym list.
     *
     */
    static final String acronymExceptions = "CR|DB|LTD|MR|MRS";
    
    /**
     * Compiled version of Acronym exceptions
     */
    protected  Pattern acronymExceptionspatt = null;
    
    /**
     * Obtain compiled pattern for acronym exceptions
     *
     * @return compiled Pattern
     */
    protected Pattern getAcronymExceptionsREpatt() {
        return this.acronymExceptionspatt;
    }
    
    /**
     * Obtain a locale specific compile date pattern
     */
    public Pattern datePattern() {
        return dateREpatt;
    }
    
    
    
    
    
    /** Creates a new instance of ENBrailleTable */
    public ENBrailleTable() {
        name = "English";
        postCodeREpatt = Pattern.compile(postcodeRE);
        acronymREpatt = Pattern.compile(acronymRE);
        dateREpatt = Pattern.compile(dateRE);
        acronymExceptionspatt = Pattern.compile("^[^\\w'](" + acronymExceptions
                + ")\\W");
        acronym2REpatt = Pattern.compile(acronym2RE);
        
        // Load the rules table
        
        File fd = new File("../rules/ENrules.xml");
        try{
            System.out.println("ENBrailleTable: " + fd.getCanonicalFile());
        }catch (java.io.IOException err){
            System.err.println("Fatal error with rules file, Quitting\n"+ err.toString());
            System.exit(2);
        }
        // Now load the rules
        boolean res =loadRules(fd);
        if (!res){
            System.err.println("Fatal error loading rules. Quitting");
            System.exit(2);
        }
        
    }
    
    /**
     * Analyse a string for mode and its length
     *
     * @param leftContext -
     *            characters prior to s
     * @param s -
     *            text to analyse
     * @return {@link org.dpawson.util.AnalysisResult AnalysisResult} holding
     *         mode and match length
     */
    public AnalysisResult analyse(String leftContext, String s) {
        Matcher m;
        String text;
        AnalysisResult result;
        int len;
        Pattern patt1;
        Pattern patt2;
        
        result = new AnalysisResult();
        result.mode = Modes.DEFAULT;
        text = s.toUpperCase();
        
        // Postcode?
        patt1 = Pattern.compile("[^A-Z0-9]$");
        m = patt1.matcher(leftContext);
        if (m.find()) {
            patt2 = postCodeREpatt;
            m = patt2.matcher(text);
            if (m.lookingAt()) {
                result.mode = Modes.POSTCODE;
                result.length = m.group(1).length();
                return result;
            }
        }
        
        // Test for Roman Numeral prior to acronym
        
        int matchLen = isRomanNumeral(leftContext, text);
        if (matchLen > 0){
            result.mode=Modes.ROMANNUMERAL;
            result.length=matchLen;
            return result;
        }
        
        
        // Test for acronym
        /**
         *Logic is
         * if leftContext matches
         *   if text is not an acronym Exception
         *     if text isAcronym()
         *        then its an acronym
         **/
        
        //Left context is ' or non word character
        patt1 = Pattern.compile("[^\\w']$");
        //Acronym exception list or non word Character
        patt2 = Pattern.compile("^(" + acronymExceptions + ")\\W");
        m = patt1.matcher(leftContext);
        if (m.find()) {  //If left context match
            m = patt2.matcher(text);
            if (!(m.find())) { // if not an acronym exception
                if ((len = isAcronym(leftContext, text)) > 0) { // if in acronym list
                    result.mode = Modes.ACRONYM;
                    result.length = len;
                    return result;
                }
            }
        }
        
        // Check for a Date?
        patt1 = Pattern.compile("[^A-Z0-9]$");
        m = patt1.matcher(leftContext);
        if (m.find()) {
            //patt2 = Pattern.compile("^(\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4})");
            patt2 = dateREpatt;
            m = patt2.matcher(text);
            if (m.lookingAt()) {
                result.mode = Modes.DATE;
                result.length = m.group().length();
                return result;
            }
            
            
        }
        return result;
    }
    
    /**
     * Read in file and build Arraylist
     *
     * @param acronymsFile
     *            name of file holding acronyms
     * @return acronyms, as an arraylist.
     */
    public boolean addAcronyms(String acronymsFile) {
        ArrayList acronyms = null;
        this.acronyms = acronyms;
        // @TODO read in and build
        return true;
    }
    
    /**
     * Retrieve the name of the table
     */
    
    public String getName() {
        return this.name;
    }
    
    /**
     *
     * @param s
     *            string to be checked.
     * @return boolean true if input string has a date as first match
     *
     */
    public boolean isDate(String s) {
        // System.err.println("isDate: called with ["+ s+"]");
        // Pattern p =Pattern.compile(this.dateRE);
        Pattern p = dateREpatt;
        Matcher m = p.matcher(s);
        return m.lookingAt();
    }
    
    /**
     * Determine if string contains an acronym at start of string
     *
     * @param leftContext -
     *            String prior to t
     * @param t
     *            input string
     * @return length of acronym or zero for null match
     *
     */
    public int isAcronym(String leftContext, String t) {
        Pattern patt1;
        Pattern patt2;
        Matcher m;
        int res = 0;
        
        // If left Context is a word
        patt1 = Pattern.compile("[^\\w']$");
        m = patt1.matcher(leftContext);
        if (m.find()) {
            
            // Then match against acronym list
            patt2 = Pattern.compile("^(([A-Z][A-Z]*[0-9]+[A-Z0-9]*)|"
                    + _acronyms + ")\\W");
            m = patt2.matcher(t);
            
        }
        // return group 1 length if match
        if (m.lookingAt()) {
            return m.group(1).length();
        }
        patt1 = Pattern.compile("[^\\w']$");
        patt2 = Pattern
                .compile("^([BCDFGHJKLMNPQRSTVWXZ][BCDFGHJKLMNPQRSTVWXZ]+)\\W");
        
        m = patt1.matcher(leftContext);
        if (m.find()) {
            m = patt2.matcher(t);
            if (m.lookingAt()) {
                return m.group(1).length();
            }
            
        }
        
        return res;
    }
    
    /**
     *Is the text a valid Roman numeral?
     *@param leftContext - Left context
     *@param src - Source string to test
     *@return - length of match, or zero if no match
     *
     *
     **/
    public static int isRomanNumeral(String leftContext, String src){
        String text = src.toUpperCase();
        StringTokenizer st = new StringTokenizer(text);
        if (st.countTokens() > 1){
            text = st.nextToken();
            //System.out.println(st.countTokens()+" tokens");
        }
        int res = 0;
        Pattern patt1 = Pattern.compile("[\\s]+$");
        Pattern patt2 =Pattern.compile("(^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3}))[\\s!\"+,-./:;<=>?\\[\\]^{|}~-]");
        Matcher m;
        m = patt1.matcher(leftContext);
        if (m.find()){
            m = patt2.matcher(text);
            if (m.lookingAt()){
                return m.group(1).length();
            }    
        }  
        return res;
    }
    
    
    
    
    /**
     * Process a date?
     *
     * @param s
     *            Input string containing date
     * @param len -
     *            length of date to process
     * @return Transcribed input as StringBuilder
     */
    public StringBuilder doDate(String s, int len) {
        // System.err.println("dodate:Processing "+ s);
        int i;
        String t = "";
        StringBuilder sb = new StringBuilder();
        
        sb.append('#');
        for (i = 0; i < len; i++) {
            t = s.substring(i, i + 1);
            if ((t.equals("/")) || (t.equals("-")))
                sb.append("#");
            if (t.equals("0"))
                sb.append("J");
            if (t.equals("1"))
                sb.append("A");
            if (t.equals("2"))
                sb.append("B");
            if (t.equals("3"))
                sb.append("C");
            if (t.equals("4"))
                sb.append("D");
            if (t.equals("5"))
                sb.append("E");
            if (t.equals("6"))
                sb.append("F");
            if (t.equals("7"))
                sb.append("G");
            if (t.equals("8"))
                sb.append("H");
            if (t.equals("9"))
                sb.append("I");
            
        }
        
        // System.err.println("date is " +sb.toString());
        return sb;
    }
    
    /**
     * Calculate the length of a date string
     *
     * @return length of date as int. zero if none found
     * @param s
     *            Input string containing the date
     */
    public int getDateLength(String s) {
        // System.err.println("getDateLength: called with ["+ s+"]");
        Pattern p = Pattern.compile(this.dateRE);
        
        Matcher m = p.matcher(s);
        if (m.lookingAt())
            return m.end() - m.start();
        else
            return 0;
    }
    
    /**
     * Test entry
     */
    public static void main(String args[]) {
        ENBrailleTable t = new ENBrailleTable();
        
        System.out.println(t.rules.length + " rules built");
        
        
        int n = t.getRuleNumber(" ", "across ", 2);
        System.out.println("rule " + n);
        
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

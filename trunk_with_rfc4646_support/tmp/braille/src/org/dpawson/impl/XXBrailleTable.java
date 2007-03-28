/*
 * XXBrailleTable.java
 *
 * Created on 21 September 2006, 08:03
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.impl;

import java.io.File;
import java.util.ArrayList;
import java.util.regex.Pattern;

import org.dpawson.util.AnalysisResult;
import org.dpawson.util.Modes;

/**
 *
 * @author dpawson
 */
public class XXBrailleTable extends BrailleTable {
    
    
    /**
     * Post code RE
     */
    protected static final String postcodeRE = "";
    // en = ^[^A-Z0-9]([A-Z][A-Z]?[0-9][0-9]? [0-9][A-Z][A-Z])
    
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
     * Valid pipe separated acronym list for lang en
     */
    private static final String _acronyms = "";
    // en = GB|PO|BIC|IBAN|RNIB|USA|VAT
    
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
    private static final String acronym2RE = "";
    // en = ^[^\\w']([A-Z]+[0-9]+)\\W
    
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
    protected static final String dateRE = "";
    // en =^\\d\\d?[\\.\\-/]\\d\\d?[\\.\\-/]\\d{2,4}
    
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
     * against the acronym list.
     *
     */
    static final String acronymExceptions = "";
    //en = CR|DB|LTD|MR|MRS
    
    /**
     * Compiled version of Acronym exceptions
     */
    protected static Pattern acronymExceptionspatt = null;
    
    /**
     * Obtain compiled pattern for acronym exceptions
     *
     * @return compiled Pattern
     */
    protected Pattern getAcronymExceptionsREpatt() {
        return Pattern.compile(acronymExceptions);
    }
    
    /**
     * Obtain a locale specific compile date pattern
     */
    public Pattern datePattern() {
        return dateREpatt;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /**
     *   Read in file and build Arraylist
     * @param acronymsFile of file holding acronyms
     * @return acronyms, as an arraylist.
     **/
    public boolean addAcronyms(String acronymsFile){
        ArrayList acronyms=null;
        this.acronyms = acronyms;
        //@TODO read in and build
        return true;
    }
    
    /** Creates a new instance of XXBrailleTable
     *This is in place as a test for language additions.
     *
     *
     */
    public XXBrailleTable() {
        name="Language XX";
        postCodeREpatt = Pattern.compile(postcodeRE);
        acronymREpatt = Pattern.compile(acronymRE);
        dateREpatt = Pattern.compile(dateRE);
        acronymExceptionspatt = Pattern.compile("^[^\\w'](" + acronymExceptions
                + ")\\W");
        acronym2REpatt = Pattern.compile(acronym2RE);
        
        // Load the rules table
        
        File fd = new File("../rules/XXrules.xml");
        try{
            System.out.println("XXBrailleTable: " + fd.getCanonicalFile());
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
    
    
    public String getName(){
        return this.name;
    }
    
    
    /**
     *Retrieve a specific contraction information
     **/
    public String getContraction(int i){
        return rules[i].OUTPUT;
    }
    
    /**
     *Retrieve a specific Shift information
     **/
    public int getShift(int i){
        return rules[i].SHIFT;
    }
    
    
    
    
    /**
     *Determine if a string contains a date
     *
     **/
    public  boolean isDate(String s){
        //@TODO implement
        return false;
    }
    
    /**
     * Process a date
     *
     * @param s - Input string containing date
     *@param len - length of date to process
     * @return Transcribed input as StringBuilder
     */
    public  StringBuilder doDate(String s, int len) {
        
        StringBuilder sb = null;
        return sb;
    }
    
    /**
     *Determine if the string contains an acronym
     **/
    public int isAcronym(String prevChar, String s){
        //@TODO implement
        return 0;
    }
    
    
    
    /**
     *Retrieve the length of the date string
     *
     **/
    public  int getDateLength(String s) {
        //@TODO implement
        return 0;
    }
    /**
     *
     * Process a post code
     **/
    public  String  DoPostCode(String s){
        //@TODO implement
        return "";
    }
    /**
     *
     *Process a date string
     **/
    public  String DoDate(String s){
        //@TODO implement
        return "";
    }
    public  AnalysisResult analyse(String leftContext, String s){
        
        AnalysisResult res = new AnalysisResult();
        res.mode=Modes.DEFAULT;
        res.length = s.length();
        
        return res;
        
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


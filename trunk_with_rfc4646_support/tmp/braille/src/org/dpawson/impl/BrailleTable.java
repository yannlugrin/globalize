/*
 * BrailleTable.java
 *
 * Created on 18 September 2006, 13:33
 *
 */
package org.dpawson.impl;

import org.dpawson.util.AnalysisResult;

import nu.xom.*;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.dpawson.util.Localizer;

/**
 * Abstract braille Table, implemented by any language. Holds all translation
 * data, list of acronyms, date processing, i.e. all those elements which are
 * wholly language dependent such as date and post code processing
 *
 * @author dpawson
 */
//@TODO FIXME. Should the methods be in a separate class, perhaps in a table package?
public abstract class BrailleTable {
    /**
     * Name of the Table, normally the language, e.g. 'French Canadian'
     */
    String name;
    
    /**
     * Namespace used in the rules table - Used by the xom reader
     */
    private final String rulesNS = "http://www.dpawson.co.uk/ns#";
    
    /**
     * Acronym table
     */
    ArrayList acronyms;
    
    /**
     * Regex String for date Expression - Must be overridden
     */
    protected String dateRE = "";
    
    /**
     * Post code RE - Must be overridden
     */
    protected String postcodeRE = "";
    
    /**
     * Compiled patterns, for efficiency Postcode, acronym, date, acronym
     * Exceptions and second acronym RE
     */
    
    /**
     * Obtain the compiled Pattern for a postCode
     * @return compiled pattern
     */
    protected abstract Pattern getPostCodeREPatt();
//	protected static Pattern postCodeREpatt = null;
    
    /**
     * Obtain compiled pattern for an acronym
     * @return compiled pattern for an acronym
     */
    protected abstract Pattern getAcronymREPatt();
    //protected static Pattern acronymREpatt = null;
    
    /**
     * Obtain compiled Acronym pattern (2)
     * @return compiled Pattern
     */
    protected abstract Pattern getAcronym2REpatt();
    //protected static Pattern acronym2REpatt = null;
    
    
    
    
    
    /**
     * Obtain compiled Pattern for a date
     * @return compiled Pattern
     */
    protected abstract Pattern getDateREpatt();
    //protected static Pattern dateREpatt = null;
    
    /**
     * Obtain compiled pattern for acronym exceptions
     * @return compiled Pattern
     */
    protected abstract Pattern getAcronymExceptionsREpatt();
    
    //protected static Pattern acronymExceptionspatt = null;
    
    
    
    /**
     * Array of rules used for translation
     *
     * @see org.dpawson.impl.Rule
     */
    Rule rules[] = null;
    
    /**
     * Total count of rules
     */
    private int rulecount = 0;
    
    
    /**
     * Obtain total count of rules loaded
     *
     * @return integer count, zero based
     */
    public int getRulesTotal(){
        return this.rulecount;
    }
    
    /**
     * ruleNumber - Only used whilst building optimisation table
     */
    private int ruleNumber = 0;
    
    /**
     * Optimisation table, content form is 'string' : int Indexes into the rules
     * table for faster access.
     */
    HashMap<String, Integer> optimisationTable = new HashMap<String, Integer>();
    
    
    /**
     *Localizer for I18N messages
     **/
   Localizer loc=null;
    
    /**
     *
     * Creates a new instance of BrailleTable
     *
     */
    public BrailleTable() {
        loc = new Localizer(this.getClass()); 
    }
    
    /**
     * Retrieve the name of the table - Most often the language for which the table is intended.
     */
    public abstract String getName();
    
    /**
     * Add a file of acronyms to the internal list
     *
     */
    public abstract boolean addAcronyms(String acronymsFile);

    
    /**
     * Determine if a string contains a date
     *
     */
    public abstract boolean isDate(String s);
    
    /**
     * Process a date
     *
     * @param s -
     *            Input string containing date
     * @param len -
     *            length of date to process
     * @return Transcribed input as StringBuilder
     */
    public abstract StringBuilder doDate(String s, int len);
    
    /**
     * Determine if the the string is an acronym. Locale specific
     */
    public abstract int isAcronym(String prevChar, String t);
    
    /**
     * Retrieve the length of the date string
     *
     */
    public abstract int getDateLength(String s);
    
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
    public abstract AnalysisResult analyse(String leftContext, String s);
    
    
    /**
     * Retrieve appropriate rule number; Note the restriction on textIn
     * <p>
     * The regex matching is as follows:
     * The first match uses ^ + rule[i].lftContext against <b>leftContext</b>
     *      and uses find()  which seeks a match anywhere
     * The second match uses rule[i].input + rule[i].rtContext $  against <b>s</b>
     *      and uses matches() which is a full match
     *<p>
     *<p>
     * If the first match succeeds, the second is tried.
     * We believe this is necessary.
     *
     * I found this difficult to comprehend and test. YMMV
     *</p>
     *<p>Note. If the input <b>textIn</b> has trailing text, then the grade I code
     *may cause a good match to be ignored. This is because no contraction is required
     *for grade I and a match on a part string causes the test
     *<code>  if (rules[ruleNumber].OUTPUT.length() < rules[ruleNumber].SHIFT)</code>
     *to be true, which then causes a continued search. This is generally not desirable,
     *hence ensure (for instance) no unwanted trailing spaces</p>
     *
     *
     *
     * @param prevString
     *            chars immediately preceding the input text
     * @param textIn
     *            input string - must always be two characters long, to match (minimally) the last rule, i.e. the character
     * followed by any single character (rule.rightContext regex)
     *
     * @param grade
     *            Grade in use for the transform
     * @return integer rule number
     */
    public int getRuleNumber(String prevString, String textIn, int grade) {
        int ruleNumber = 0;
        Matcher m = null;
        String regex = ""; // looping regex.
        Pattern patt1 = null;
        Pattern patt2 = null;
        String text = textIn; // copy of input text
        String c = ""; // first character of current text
        // reject rules having contractions, if working grade 1
        boolean rejectRule = true; //
        boolean term = false; // true to terminate the do while loop
        
        //System.out.println("BrailleTable.GetRuleNumber: matching on [" + prevString+text + "]");
        
        if (text.length() == 0) {
            //System.err.println("GetRuleNumber, zero Len input string\n Quitting ");
            System.exit(2);
        }
        // Get the rule number to start from, from the optimisation table
        
        c = text.substring(0, 1).toUpperCase(); // First char, uppercase
        if (!optimisationTable.containsKey(c)) {
            text = "*" + text.substring(1, text.length());
            c = "*";
        }
        
        ruleNumber = optimisationTable.get(c);         
        do {
             term = false; // Don't terminate. 
            patt1 = Pattern.compile(rules[ruleNumber].LEFTCONTEXT + "$",
                    Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
            
            regex = "^" + rules[ruleNumber].INPUT
                    + rules[ruleNumber].RIGHTCONTEXT; // ignore case
            patt2 = Pattern.compile(regex, Pattern.CASE_INSENSITIVE
                    | Pattern.UNICODE_CASE);
            
            // (1)  Check for match on left context
            m = patt1.matcher(prevString);
            if (m.find()) {
                //(2) Check for match on input text, as far as possible
                m = patt2.matcher(text);
                if (m.lookingAt()) {
                    // then we have found the rule
                    term = true; // exit the loop, match found
                }
            }
            rejectRule = false;
            if (grade == 1) {
                // Ignore rules that contract for grade 1
                if (rules[ruleNumber].OUTPUT.length() < rules[ruleNumber].SHIFT){
                    rejectRule = true;
                   
                }
            }
            m.reset(); // clear down the match
            
            ruleNumber++;
            if (ruleNumber > (rulecount + 1) ) {
                System.err.println(loc.message("badrulenumber", ruleNumber));
                //System.err.println("BrailleTable.getRuleNumber: Overrun");
                System.err.println(" [{" + prevString+"}" + text + "]. Quitting");
                System.exit(2);
            }
        } while ((!term || rejectRule)); // && (ruleNumber <= this.rulecount)
        ruleNumber--;
        return ruleNumber;
    }
    
    /**
     * Load the rules{@linkplain #rules rules}} from an XML file.
     *
     * @param fd -
     *            File holding rules
     * @return true - Valid rule set, false - invalid
     */
    public boolean loadRules(File fd) {
        
        boolean res = true;
        // Set up the XML document.
        Document doc = null;
        try {
            Builder parser = new Builder(false); // don't validate'
            doc = parser.build(fd);
        } catch (ValidityException ex) {
            doc = ex.getDocument();
            System.err.println(loc.message("rulesfileinvalid", fd.getAbsolutePath()));
            //System.err.println("Invalid rules file");
            res = false;
            
        } catch (ParsingException ex) {
            System.err.println(loc.message("notwellformed", fd.getAbsolutePath()));
//            System.err
//                    .println("Rules file is malformed today. (How embarrassing!)"
//                    + fd.getAbsoluteFile());
            res = false;
            
        } catch (IOException ex) {
            System.err.println(loc.message("rulesnotfound",  fd.getAbsolutePath()));
//            System.err.println("Could not open rules file at "
//                    + fd.getAbsolutePath());
            res = false;
        }
        if (!res)
            return res;
        
        
        Element root = doc.getRootElement();
        // Firstly load the rulecount.
        rulecount = getRuleCount(root);
        
        // Now create the optimisationTable
        this.rules = new Rule[rulecount + 1];
        
        // System.out.println("Loading rules");
        
        Elements groups = root.getChildElements("group", rulesNS);
        for (int i = 0; i < groups.size(); i++) {
            processGroup(groups.get(i));
        }
        
        return res;
    }// end of load rules
    
    /**
     * Process each group of rules
     *
     * @param el
     *            the element holding the groups.
     */
    private void processGroup(Element el) {
        if (el instanceof Element) {
            Element temp = (Element) el;
            String gi = temp.getLocalName();// element name
            if (gi.equals("group")) {
                prGroup(temp);
            }
        }
    }
    
    /**
     * Process a group of rules from the xml file, adding to {@linkplain #optimisationTable optimisationTable } as each group is processed
     *
     * @param nd
     *            is the node of rules
     */
    private void prGroup(Node nd) {
        if (nd instanceof Element) {
            Element el = (Element) nd;
            // Find the first rule child
            Element gp = el.getFirstChildElement("rule", rulesNS);
            if (gp != null) {
                // Find first input child
                Element inp = gp.getFirstChildElement("input", rulesNS);
                if (inp != null) {
                    // Get the prefix
                    String key = inp.getValue().substring(0, 1);// Start Char
                    // If it is escaped (preceded by \, use second character
                    if (key.charAt(0) =='\\'){
                            key=inp.getValue().substring(1);
                            
                    }
                    // and load the optimisation table
                    if (!optimisationTable.containsKey(key)) {
                        optimisationTable.put(key, ruleNumber);
                        //System.out.println("Adding key "+ key+" for rule "+ruleNumber);
                    }
                    // Now find and process rules in this group
                    Elements rules = el.getChildElements("rule", rulesNS);
                    //System.out.println("prGroup: "+key+" "+ rules.size());
                    for (int i = 0; i < rules.size(); i++) {
                        
                        Element rule = rules.get(i);
                        processRule(rule);
                    }
                } else {
                    System.out
                            .println("BrailleTable.prGroup: No input element "
                            + gp.getValue());
                }
            } else
                System.out
                        .println("BrailleTable.prGroup: no rules in this group");
        } else
            System.out.println("BrailleTable.prGroup: Not an element");
    }
    
    /**
     * Process a single rule, add to rules array.
     * Note. If loading the rules causes a null pointer exception, look for
     * an empty element in the rules file
     */
    
    private void processRule(Element rule) {
        Elements leftContext = rule.getChildElements("lftContext", rulesNS);
        Elements input       = rule.getChildElements("input", rulesNS);
        Elements rightContext = rule.getChildElements("rtContext", rulesNS);
        Elements output      = rule.getChildElements("output", rulesNS);
        Elements shift       = rule.getChildElements("inputShift", rulesNS);
        Elements ruleNum     = rule.getChildElements("ruleNum", rulesNS);
        if (input.size() == 0) {
            System.out.println("null input");
            return;
        }
        // System.out.print(ruleNum.get(0).getValue()+" ");
        String leftContexts = "LEFT";
        String inputs = "INPUT";
        String rightContexts = "RIGHT";
        String outputs = "OUTPUT";
        int inputShift = 0;
        int ruleNumi = 99999;
        if (ruleNum.size() == 1) {
            ruleNumi = Integer.parseInt(ruleNum.get(0).getValue());
        }
        if (leftContext.size() == 1) {
            leftContexts = leftContext.get(0).getValue();
        }
        if (input.size() == 1){
            inputs = input.get(0).getValue();
        }
        if (rightContext.size() == 1) {
            rightContexts = rightContext.get(0).getValue();
        }
        if (output.size() == 1) {
            outputs = output.get(0).getValue();
        }
        if (shift.size() == 1) {
            inputShift = Integer.parseInt(shift.get(0).getValue());
        }
        
        if (inputs.equals("")) {
            System.out.println("\t\tempty input, rule " + ruleNumi + " output "
                    + outputs);
            System.exit(2);
        }
        
        Rule r = new Rule();
        
        r.LEFTCONTEXT = leftContexts; // left Context
        r.RIGHTCONTEXT = rightContexts; // right Context
        r.INPUT = inputs;
        r.OUTPUT = outputs;
        r.SHIFT = inputShift;
        r.RULENUMBER = ruleNumber; // load ruleNumber from incremented count,
        // not value
        rules[ruleNumber] = r;
        // System.out.println(leftContexts+" "+rightContexts+" "+inputs+" "+
        // outputs + " "+ inputShift);
        // System.out.println(inputs+" " + ruleNumber);
        ruleNumber++; // increment rule number
        
    }
    
    /**
     * get Count of rules in rulesfile
     */
    private int getRuleCount(Node root) {
        int res = 0;
        if (root instanceof Element) {
            Element rt = (Element) root;
            Elements groups = rt.getChildElements("group", rulesNS);
            // System.out.println(" groups: "+ groups.size());
            if (groups.size() > 0) {
                Element lastGroup = groups.get(groups.size() - 1);
                Elements rules = lastGroup.getChildElements("rule", rulesNS);
                // System.out.println("rules "+ rules.size());
                if (rules.size() != 0) {
                    Element lastRule = rules.get(rules.size() - 1);
                    res = Integer.parseInt(lastRule.getFirstChildElement(
                            "ruleNum", rulesNS).getValue());
                }
            }
            
        }
        // System.out.println(" There are " + res +" rules");
        return res;
    }
    
    /**
     * Retrieve a specific contraction information
     */
    public String getContraction(int i) {
        return rules[i].OUTPUT;
    }
    
    /**
     * Retrieve the shift value for a rule i
     * @param i - the rule for which the shift is required
     * See {@link org.dpawson.impl.Rule#SHIFT SHIFT }
     */
    public int getShift(int i) {
        return rules[i].SHIFT;
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

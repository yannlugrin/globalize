
/*
 * Paragraph.java
 *
 * Created on 21 September 2006, 09:36
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.format;

import org.dpawson.util.Utils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.StringTokenizer;
import org.dpawson.util.Localizer;
import org.dpawson.util.Test;

/**
 * A block level element in a braille file - formatted paragraph
 * @author dpawson
 *
 */
public class Paragraph {
    
    /**
     *Revision
     **/
    public static final String version="1.0";
    
    
    /**
     * Provision of output
     */
    // private myWriter writer;
    /**
     * Size of one line, in characters/cells
     */
    private int LINE_SIZE = 0;
    
    /**
     * The line into which output is built
     */
    private String line = "";
    
    /**
     * Size of a single tab, in characters/cells
     */
    private static final int HTAB = 2;
    
    /**
     * Current indent, cells wrt 0, used for all but first line of indented paragraphs
     */
    private int indent = 0;
    
    /**
     * Current horizontal position within the line being built for output
     */
    private int hpos = 0;
    
    /**
     * true => newline just written. false=> newline not just written.
     * Compare this with firstLine, which is true only whilst processing up to
     * the first line break in the Paragraph
     */
    private boolean newline = true;
    
    /**
     * true whilst processing the first line (in output) of a Paragraph, otherwise false
     **/
    private boolean firstLine= true;
    
    
    /**
     *Message handler for I18N
     **/
    Localizer loc=null;
    
    /**
     * Constructor - Checks and sets the {@link #LINE_SIZE LINE_SIZE} then calls {@link #clear()}
     *
     * @param colsPerLine
     *                number of cells for the lines to be built
     */
    public Paragraph(int colsPerLine) {
        this.loc=new Localizer(this.getClass());
        if ((colsPerLine < 40) && (colsPerLine > 10)) {
            this.LINE_SIZE = colsPerLine;
        } else {
            System.err.println(loc.message("badcols", colsPerLine));
            System.exit(2);
        }
        clear();
    }
    
    /**
     * Clear out the paragraph
     */
    public void clear() {
        this.line      = "";
        this.newline   = true;
        this.firstLine = true;
        this.hpos      = 0; // reset line marker
        this.indent    = 0; // reset indent
    }
    
    /**
     * Process a paragraph by splitting up into lines, <b>Warning: </b>This
     * method normalizes whitespace. Leaves the formatted string in {@link #line line} accessed
     *by contents
     *
     * @param s
     *                is the string to process
     * @return formatted lines
     *
     */
    public String prPara(String s) {
        clear();
        String res;
        // StringTokenizer words = new StringTokenizer(s); // @TODO replace with
        // ws
        // respecting selection
        StringTokenizer words = new StringTokenizer(s, "[ \t\n\r\f]+", true);
        while (words.hasMoreTokens()) {
            prWord(words.nextToken());
        }
        res = this.line;
        return res;
    }
    
    
    
    
    
    
    /**
     * Process a paragraph by splitting up into lines, <b>Warning: </b>This
     * method normalizes whitespace.
     * Leaves the formatted text in line, obtained through contents
     *
     * @param s
     *                is the string to process
     * @param startIndent
     *                cell indent for first line
     * @param restIndent
     *                cell indent for remaining lines
     * @return formatted lines
     *
     */
    public String prPara(String s, int startIndent, int restIndent) {
        clear(); // start from fresh.
        String res = ""; // result string
        String wkg = ""; // working value
        //Check for valid first line indent
        if (validateIndent(startIndent)) {
            for (int i = 0; i < startIndent; i++) {
                write(" "); // output startIndent whitespace
                hpos += 1; // increment position
            }
            
            wkg = org.dpawson.util.Utils.ltrim(s);
        }
        // Check for valid indent for remaining lines
        if (validateIndent(restIndent)) {
            this.indent = restIndent;
        } else {
            // Invalid prPara.restIndents. Ignored;
        }
        StringTokenizer words = new StringTokenizer(wkg, "[ \t\n\r\f]+", true);
        
        while (words.hasMoreTokens()) {
            prWord(words.nextToken());
        }
        res = this.line;
        return res;
    }
    
    
    /**
     * Process a single word to the output stream, accounting for line
     * overflow. Makes use of {@link #hpos} and {@link #indent} Indent is
     * added only when processing content other than the first line.
     * <p>
     * Logic: Options are <br />
     * 1. New para (hpos == 0), normal words <br />
     * 2. New para (hpos == 0), single <br />
     * long (longer than LINE_SIZE) word <br />
     * 3. existing para (hpos > 0), normal word <br />
     * 4. existing para (hpos > 0), long word. <br />
     * </p>
     *
     * @param word
     *                input text to add to output stream
     * @see #lineBreak()
     */
    
    private void prWord(String word) {
        if (hpos + word.length() > LINE_SIZE) {
            lineBreak(); // If this word won't fit, wrap.
            
        }
        if (word.length() >= LINE_SIZE) {
            prLongWord(word);
        } else // word can be processed, i.e. it is short enough to fit
        {
            
            
            // Test for ws immediately after newline
            if (newline && word.startsWith(" ") && !firstLine){
                hpos += word.length();
                write(word.substring(1));
            } else{ // newline and ws starting
                write(word);
                hpos +=word.length();
            }
        }
        newline = false;
    }
    
    
    
    /**
     * Validate an indent value, Must be odd and {1..9}
     *
     * @param val
     *                input integer value to test
     * @return true if sensible value
     */
    private boolean validateIndent(int val) {
        boolean res = false;
        if ((val % 2) == 1) {
            if ((val > 0) && (val < 11))
                res = true;
        }
        return res;
    }
    
    /**
     * Write a string to the output stream
     *
     *
     * @param string
     */
    // TODO check this is correct output stream, then document it here
    private void write(String string) {
        // writer.write(string);
        this.line += string;
        
    }
    
    /**
     * Convert a paragraph to an arraylist for better processing.
     * Note that the method adds a linefeed to the end of the input
     * Split is at any embedded newline characters
     *
     * @param p
     *                String with linebreaks
     * @return Arraylist containing conversion.
     */
    public ArrayList <String> paraToBlock(String p) {
        int newline = 10; // newline codepoint
        ArrayList<String> b = new ArrayList<String>();
        b.clear();
        String line = "";
        for (int i = 0; i < p.length(); i++) {
            if (p.codePointAt(i) == newline) {
                b.add(line);
                line = "";
            } else {
                line += p.charAt(i);
            }
        }
        b.add(line); //
        return b;
    }
    
    /**
     * Process a single very long word
     *
     * @param word
     *                a long word which needs splitting
     */
    private void prLongWord(String word) {
        String partWord = "";
        int smallerWords = word.split("\\W").length;
        if (smallerWords > 1) {
            StringTokenizer words = new StringTokenizer(word,
                    "!\"£$%^&*()_+-=;,./?", true);
            while (words.hasMoreTokens()) {
                partWord = words.nextToken();
                hpos += partWord.length();
                if (hpos >= LINE_SIZE) {
                    lineBreak(true);
                }
                write(partWord);
            }
        } else { // unable to split on non-word char, force break at
            // LINE_SIZE
            if (hpos >= LINE_SIZE) {
                lineBreak();
            }
            write(word.substring(0, LINE_SIZE - 1)); // write out first part
            // of long word
            lineBreak(true); // Force new line
            // prepend indent if needed
            partWord = "";
            
            partWord += word.substring(LINE_SIZE - 1, word.length());
            write(partWord);
            if (word.substring(LINE_SIZE - 1, word.length()).length() > LINE_SIZE) {
                System.err.println(loc.message("longword",word ));
                System.exit(2);
            }
            lineBreak();
            // TODO Assumes no input is greater than two lines long
        }
        
    }
    
    
    
    
    
    
    
    
    /**
     * Write a newline character to the output if, and only if, one has
     * <b>not</b> been written immediately previously. Having written the
     * newline, return the horizontal postion to zero (@link #hpos hpos)
     *
     */
    public void lineBreak() {
        if (!newline) {
            write("\n");
            hpos = 0;
            for (; hpos < indent; hpos++) {
                write(" ");
            }
            newline = true;
            firstLine = false;
        }
    }
    
    /**
     * Write a newline character to the output stream if parameter
     * forceNewline is true, then ensure a newline char is written
     *
     *
     * @param forceNewline ensure newline is created
     */
    public void lineBreak(boolean forceNewline) {
        
        if (forceNewline) {
            lineBreak();
            
        }
    }
    
    /**
     * Retrieve the contents of the Paragraph, formatted as lines as per the specification of the Paragraph
     *@return current line
     *
     */
    public String getContents() {
        return this.line;
    }
    
    
    /**
     *Retrieve the paragraph width in cells
     *<b>Note</b> The Paragraph could have 3 newlines within it.
     * Retrieve the length of the longest possible section.
     * @return the cell count of the longest possible line
     **/
    public int getColCount(){ //@TODO Test
        int res = this.LINE_SIZE;
        return res;
    }
    
    /**
     *Retrieve the number of lines within this paragraph
     **/
    public int GetRowCount(){ //@TODO Test me.
        int res= 0;
        StringTokenizer st = new StringTokenizer(this.line,"\n");
        String [] lines = this.line.split("\n");
        if (lines.length > 1){
            while (st.hasMoreTokens()) {
                st.nextElement();
                res++;
            }
        }else {
            res =1;
        }
        return res;
    }
    
    /**
     * Outdent from current position
     *
     */
    public void unindent() {
        indent -= HTAB;
        lineBreak();
    }
    
    
    /**
     *Dump the current paragraph for tidy display
     **/
    public void dumpPara(){
        System.out.print("<<");
        int newline = 10;
        int cr = 12;
        for (int i = 0; i < this.line.length(); i++) {
            if (this.line.codePointAt(i) == newline) {
                System.out.print(">>\\n<<");
            } else if (this.line.codePointAt(i) == cr){
                
            } else {
                System.out.print(this.line.charAt(i));
                
            }
            
        }
        System.out.println(">>");
    }
    
    /**
     * Test entry for this class only
     * @param args
     */
    public static void main(String[] args) {
        Paragraph p = new Paragraph(20);
        List ls = new ArrayList();
        String cln="  Test input with 3 lines of text of <= 20 chars ";
        String input="Test input\nWith 3 lines\nof text";
        String output="";
        Test test = new Test(Paragraph.class.getCanonicalName() + ". Version "+ Paragraph.version,"ParaTestResults.txt");
        
        System.out.println("Running. Results sent to " + test.getOutputPath());
        
        output = Utils.ltrim(cln);
        Test.Assert("Test input with 3 lines of text of <= 20 chars ",output);
        
        String in ="\t \n \fxx";
        output = Utils.ltrim(in);
        Test.Assert("xx",output);
        
        in ="\t \n \f";
        output = Utils.ltrim(in);
        Test.Assert("",output);
        
        
        ls = p.paraToBlock(input); // 3 lines?
        Iterator it = ls.iterator();
        Test.Assert(3,ls.size());
        
        output = p.prPara(cln);
        Test.Assert("  Test input with 3 \nlines of text of <= \n20 chars ",output);
        
        
        System.out.println("\n\n prPara(String) test\n");
        String tmp = p.prPara(cln);
        System.out.println("["+p.line+"]");
        
        System.out.println(p.prPara(cln));
        output = p.prPara(cln,1,3);
        Test.Assert(" Test input with 3 \n   lines of text of \n   <= 20 chars ",output);
        
        tmp = p.prPara(cln,5,3);
        System.out.println("\n\nprPara(5,3) test, same content");
        System.out.println("["+p.getContents()+"]");
        
        System.out.println("Row Count should be 4, is  "+ p.GetRowCount());
        System.out.println("Col Count should be 20, is "+ p.getColCount());
        
        Test.stop();
        System.err.println("Testing finished,");
        
        
        // Test I18N - will quit
        //p = new Paragraph(78);
        p = new Paragraph(16);
        p.prLongWord("AVeryLongWordExtendingOverTwoLinesInLength");
        
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


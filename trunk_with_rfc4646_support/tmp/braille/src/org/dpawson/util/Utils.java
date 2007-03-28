/*
 * Utils.java
 *
 * Created on 21 September 2006, 09:40
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.util;


import java.util.regex.Matcher;
import java.util.regex.Pattern;
/**
 * General text manipulation utilities
 *
 * @author dpawson
 *
 */
public class Utils {
    
    /**
     *
     * Constructor. Unused.
     *
     */
    public Utils() {
        
    }
    
    /**
     * Centre text within a line of length LINE_LENGTH, which may be over more
     * than one line. Constrained to be minimum of 5 cells either end of the
     * text. <br />
     *
     * <pre>
     *       Logic. If more than two lines,
     *                   split out using findBreakPoint()
     *              else
     *                   split the line using fbreak(txt, len /2)
     *              then pad appropriately
     * </pre>
     *
     * @param txt
     * @param LINE_LENGTH
     * @return array of strings, centred (unused are empty strings), or 4 empty
     *         strings.
     */
    public static String[] center(String txt, int LINE_LENGTH) {
        /**
         * Initial split, prior to centering
         */
        int[] inter = { 0, 0, 0, 0, 0, 0, 0 };
        
        /**
         * Final result to return
         */
        String[] res = { "", "", "", "" };
        int len = txt.length();
        // Determine if a split is needed
        
        if ((len + 10) > LINE_LENGTH) {
            // Determine how the split should be done... 2 lines or more
            if (len >= (LINE_LENGTH + 20)) { // More than two lines
                inter = findBreakPoint(txt, len / (LINE_LENGTH - 10));
                int i=0;
                for (; i < inter.length - 1; i++) {
                    res[i] = centerHelper(txt.substring(inter[i],
                            inter[i + 1] - 1), LINE_LENGTH);
                }
                res[i+1]="";
            } else { // less than two lines, centre in two lines
                int bkpoint = fbreak(txt, len / 2);
                res[0]=centerHelper(txt.substring(0,bkpoint-1),LINE_LENGTH);
                res[1]=centerHelper(txt.substring(bkpoint,len),LINE_LENGTH);
            }
            return res;
        } else { // else fits in one line
            res[0] = centerHelper(txt, LINE_LENGTH);
            res[1] = "";
        }
        return res;
    }
    
    /**
     * Centre a single line <code>txt</code> within <code>LINE_LENGTH</code>
     *
     * @param txt , the input text to be centred.
     * @param LINE_LENGTH length of line in which to center the text
     * @return <b>txt>, centred in LINE_LENGTH
     */
    private static String centerHelper(String txt, int LINE_LENGTH) {
        /**
         * Result
         */
        String res = "";
        /**
         * Number of spaces to prepend
         */
        int prepend = 0;
        /**
         * Number of spaces to append
         */
        int append = 0;
        int len = txt.length();
        prepend = (LINE_LENGTH - len) / 2;
        append = LINE_LENGTH - (len + prepend);
        String spaces = "                       ";
        res = spaces.substring(0, prepend) + txt
                + spaces.substring(0,append);
        
        return res;
    }
    
    /**
     * Find a suitable breakpoint(s) in String txt to break the input String
     * into suitable length pieces, each of which will fit within
     * <code>TEXT_LENGTH</code>. Ideally at word breaks, less ideally by
     * breaking words. Max splits is ten. Preloads the result array with 0
     * (start point) and finally loads the results with the string length in the
     * final entry. An entry of -1 marks the end of the list E.g. 'A 16 char
     * string', 2, 10 =>
     *
     * [0, 9, 15, -1] i.e. first string is 0..8, second is 9..15
     *
     * @param txt
     *            input string to work on
     * @param TEXT_LENGTH
     *            overall space available
     * @return an array of indexes into the input string for the breakpoints
     */
    private static int[] findBreakPoint(String txt, int TEXT_LENGTH) {
        int[] res = new int[10]; // No more than ten sections
        int len = txt.length();
        int parts = (len / TEXT_LENGTH) + 1; // Safe number of lines.
        int i = 1;
        res[0] = 0; // for first loop
        while (i <= parts) {
            // Find an appropriate break in the line, <= (len/parts) *i
            if (((len / parts) * i) < len) { // If more to split up
                res[i] = fbreak(txt.substring(res[i]), (len / parts) * i);
                i++;
            } else {
                i++;
            }
        }
        res[i - 1] = txt.length();
        res[i] = -1;
        return res;
    }
    
    /**
     * Find a single suitable break point for string txt, before or at position
     * n in the string txt. Presumes a single split.
     *
     * @param txt
     * @param n
     * @return A suitable breakpoint, or 0 if unable to split
     */
    private static int fbreak(String txt, int n) {
        int len = txt.length();
        if ((n >= len) || txt.split(" ").length == 1) {
            return 0; // invalid call, cannot be split
        }
        txt = txt.replaceAll("\t", "    "); // expand tabs
        
        String res[] = txt.split("[ ]+"); // split the string on ws
        int max = 0;
        int idx = 0;
        
        for (int i = 0; ((i < res.length) && (idx != -1)); i++) {
            idx = txt.lastIndexOf(res[i], n); // seek last match prior to n
            if (idx > 0) {
                // System.out.println(res[i] + idx);
                if (idx > max)
                    max = idx;
            }
        }
        
        return max;// max index into string.
        // walk back down the string to find the nearest word break.
    }
    
    /**
     * Left trim an input string by removing all preceding whitespace
     *
     * @param txt
     *            input string
     * @return trimmed string
     */
    public static String ltrim(String txt) {
        String res = txt;
        String re ="^([\\s]+)";
        Pattern patt1 = Pattern.compile(re);
        Matcher m = patt1.matcher(txt);
        if (m.lookingAt()){
            res = txt.replaceFirst("^[\\s]+","");
        }
//        
//        
//        String[] tmp = null;
//        tmp = txt.split("^[\\s\\t\\n\\r\\f]+");
//        if (tmp.length > 1)
//            res = tmp[1];
        return res;
    }
    
    
    
    /**
     * Pad the txt out within a given LINE_LENGTH. Only usable when the
     * txt.length+10 <=LINE_LENGTH LINE_LENGTH
     *
     * @param txt
     *            Input text to be padded.
     * @return the padded string or the original unpadded string if no fit
     */
    private static String pad(String txt, int LINE_LENGTH) {
        String res = "";
        int len = txt.length();
        if ((len + 10) > LINE_LENGTH) {
            return txt;
            // System.err
            // .println("Utils.pad: Unable to fit text within line: Line was
            // \n\t"
            // + txt);
            // System.exit(2);
        }
        int startPad = (LINE_LENGTH - len) / 2;
        int endPad = LINE_LENGTH - (len + startPad);
        String tmp = "";
        for (int i = 0; i < startPad; i++) {
            tmp += " ";
        }
        res = tmp + txt;
        tmp = "";
        for (int i = 0; i < endPad; i++) {
            tmp += " ";
        }
        return res + tmp;
    }
    
    /**
     * Used as method test bed
     *
     * @param args
     */
    public static void main(String[] args) {
        Utils u = new Utils();
        Test test = new Test(u.getClass().getCanonicalName() + " version "
                + org.dpawson.util.Version.getVersion(), "");
        String txt = ""; // input test text
        String res = "";// result text
        String[] res1 = { "", "", "", "" };
        
        // temp testing location
        
        
        //System.exit(2);
        
        txt = "The quick brown fox nearly jumps\t over the lazy dog";
        int n = fbreak(txt, txt.length() / 2);
        Test.Assert(20, n);
        
        txt = "onctwice";
        n = fbreak(txt, txt.length() / 2);
        Test.Assert(0, n); // Can't split
        
        txt = "once twice";
        n = fbreak(txt, txt.length() / 2);
        Test.Assert(5, n);
        
        txt = "A padding test";
        
        res = pad(txt, 30);
        Test.Assert("        A padding test        ", res);
        
        txt = "Another padding test"; // fails, too long (cant get 5sp txt 5sp
        res = pad(txt, 25);
        Test.Assert("Another padding test", res);
        
        txt = "A failed padding test";
        res = pad(txt, 20);
        Test.Assert("A failed padding test", res);
        
        txt = "A long line which is meant to  fit in 20 characters, which clearly won't fit";
        // Create n strings from this line, fitting in 20 line
        int breaks[] = findBreakPoint(txt, 20);
        
        Test.Assert(0, breaks[0]);
        Test.Assert(18, breaks[1]);
        Test.Assert(38, breaks[2]);
        Test.Assert(53, breaks[3]);
        Test.Assert(76, breaks[4]);
        
        txt = "A shorter line, no split in it";
        breaks = findBreakPoint(txt, 25);
        
        Test.Assert(0, breaks[0]);
        Test.Assert(10, breaks[1]);
        Test.Assert(30, breaks[2]);
        
        txt = "\t   \t Start";
        res = ltrim(txt);
        Test.Assert("Start", res);
        
        txt = " Start ";
        Test.Assert("Start", res);
        
        txt = "Start ";
        Test.Assert("Start", res);
        
        txt = "Start";
        res1 = center(txt, 20);
        Test.Assert("       Start        ", res1[0]);
        
        txt = "Too Big To Fit String";
        res1 = center(txt, 20);
        Test.Assert("      Too Big       ", res1[0]);
        Test.Assert("   To Fit String    ", res1[1]);
        Test.Assert("", res1[2]);
        
        txt = "1234567890";
        res1 = center(txt, 30);
        Test.Assert("          1234567890          ", res1[0]);
        
        
        txt="";
        
        // ltrim
        txt = "Brief String";
        res = u.ltrim(txt);
        Test.Assert("Brief String",res);
        
        txt = "   longer String with leading space";
        res = u.ltrim(txt);
        Test.Assert("longer String with leading space",res);
        
        
        
        
        
        Test.stop();
        
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


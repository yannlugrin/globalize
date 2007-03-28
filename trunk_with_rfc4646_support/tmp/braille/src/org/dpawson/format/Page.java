
/**
 * Layout and formatting package. Concerns are with presentation only. Considered to be I18N
 * See {@link org.dpawson.format.Page#Version Version } for revision information
 * 061011T15:00:00Z
 *
 **/
package org.dpawson.format;

import java.util.ArrayList;
import java.util.StringTokenizer;
import java.util.Vector;
import org.dpawson.util.Localizer;


/**
 * @author dpawson Models a single page
 */
public class Page {
    /**
     * Revision of this class
     */
    public static final String Version = "1.0";
    
    /**
     * Lines per page - constrained to lie between {@link #minRows minRows } and {@link #maxRows maxRows } per page
     */
    private int rows = 0;
    
    /**
     * Minium row count. Constraint is for British Braille.
     */
    private final int minRows = 11; // for A5 landscape
    /**
     * Maximum row (line) count per page. Constraint is for British Braille.
     */
    private final int maxRows = 28;// for Exam papers
    
    /**
     * columns per line -  constrained to lie between {@link #minrows minCols } and {@link #maxCols maxRows } per line
     */
    private int cols = 0;
    
    /**
     * Minimum page width. Constrained by British Braille.
     */
    private final int minCols = 20; // for A5 portrait
    /**
     * Maximum column count for one page
     */
    private final int maxCols = 40; // For Perkins thermoforms
    
    
    /**
     *Number of cells reserved for pagenumber, nominally 3 separation from text, then 4 for number
     *
     **/
    private static final int PAGENUMBERSPACE = 7;
    
    /**
     * Line to use for header text.
     * Will be truncated to {@link #cols cols } - {@link #PAGENUMBERSPACE space} cells
     * such that the page number max 3 digits can be inserted.
     * Otherwise truncated to {@link #cols cols } cells if no header is present.
     */
    private String headerText = "";
    
    /**
     * Line to use for footer. Unused in en-UK braille
     */
    //private Block footer = null;
    
    
    /**
     *Indicator that this page has a header. Set by constructor.
     **/
    private boolean hasHeader=false;
    
    
    
    /**
     * String array  into which a page is built
     *
     **/
    private ArrayList <String> text =null;
    
    
    
    
    /**
     *Page number - autoincremented by page break, otherwise wholly controlled by the calling application
     *
     **/
    private int pageNumber=1;
    
    
    
    /**
     *Indicator - true when page is full and needs processing
     **/
    boolean pageFull=false;
    
    /**
     * Inner Block class, used to build an array of lines of text.
     *
     * @author dpawson
     *
     */
//    private class Block {
//        String[] text = null;
//
//        /**
//         * Constructor. Build a new block of <b>lines</b> lines.
//         *
//         * @param lines
//         */
//        Block(int lines) {
//            text = new String[lines];
//        }
//    }
    
    /**
     * Constructor presents major properties {@link #rows rows} and {@link #cols cols}
     * @param linesPerPage - required number of rows per page
     * @param colsPerLine  - required number of columns per row (cells)
     * @param headerText - Required Header text {@link #addHeader addHeader}
     * @param pageNumber - starting page number
     */
    public Page(int linesPerPage, int colsPerLine, String headerText, int pageNumber) {
        this.text = new ArrayList<String>(linesPerPage);
        
        if ((linesPerPage < 40) && (linesPerPage > 10)) {
            // Leave room for one line header
            this.rows = linesPerPage - 1;
            this.hasHeader = true;
        } else {
            System.err.println("Invalid lines per page request of"
                    + linesPerPage + ". Quitting");
            System.exit(2);
        }
        if ((colsPerLine < 40) && (colsPerLine > 10)) {
            this.cols = colsPerLine;
        } else {
            System.err.println("Invalid cols per line request of" + colsPerLine
                    + ". Quitting");
            System.exit(2);
        }
        // set up the header
        this.addHeader(headerText, true);
        this.setPageNumber(pageNumber);
        
        
        this.pageFull=false;
    }
    
    
    /**
     * Constructor presents major properties {@link #rows rows} and {@link #cols cols}
     * @param linesPerPage - required number of rows per page
     * @param colsPerLine  - required number of columns per row (cells)
     * @param headerText - Required Header text {@link #addHeader addHeader}
     * No page numbering required
     */
    public Page(int linesPerPage, int colsPerLine, String headerText) {
        this.text = new ArrayList<String>(linesPerPage);
        
        if ((linesPerPage < 40) && (linesPerPage > 10)) {
            // Leave room for one line header
            this.rows = linesPerPage - 1;
            this.hasHeader = true;
        } else {
            System.err.println("Invalid lines per page request of"
                    + linesPerPage + ". Quitting");
            System.exit(2);
        }
        if ((colsPerLine < 40) && (colsPerLine > 10)) {
            this.cols = colsPerLine;
        } else {
            System.err.println("Invalid cols per line request of" + colsPerLine
                    + ". Quitting");
            System.exit(2);
        }
        // set up the header
        this.addHeader(headerText, false);
        this.pageFull=false;
    }
    
    
    
    /**
     * Constructor presents major properties {@link #rows rows} and {@link #cols cols}
     * @param linesPerPage - required number of rows per page
     * @param colsPerLine  - required number of columns per row (cells)
     */
    public Page(int linesPerPage, int colsPerLine) {
        this.text = new ArrayList<String>(linesPerPage);
         Localizer loc = new Localizer(this.getClass());
        if ((linesPerPage < 40) && (linesPerPage > 10)) {
            this.rows= linesPerPage;
            this.hasHeader = false;
        } else {
           
            String msg = loc.message("badrows", linesPerPage);
            System.err.println(msg);
            System.exit(2);
        }
        if ((colsPerLine < 40) && (colsPerLine > 10)) {
            this.cols = colsPerLine;
        } else {
             System.err.println(loc.message("badcols", colsPerLine));
//            System.err.println("Invalid cols per line request of" + colsPerLine
//                    + ". Quitting");
            System.exit(2);
        }
        this.pageFull=false;
    }
    
    
    
    
    /**
     * Load the header with text and / or pagenumber - contracted or not as appropriate
     * @param header - String to use for header, will be truncated to cols - 7 to cater for page number if used
     * @param pageNumber - include space for a pageNumber
     **/
    public void addHeader(String header, boolean pageNumber){
        int lineLength = this.cols; // max line length
        if (pageNumber ){
            lineLength = lineLength - this.PAGENUMBERSPACE; // reserve space for pagenumber
        }
        this.headerText=header.substring(0,lineLength -1); // Truncate to max
        
    }
    
    
    
    /**
     * Add a line(s) to the page
     *
     * @param lines
     *            to be added
     * @param keepWithPrevious
     *            mandate to keep this line with previous ones
     * @return true implies lines were added, false implies none of the text was
     *         added
     */
    public boolean add(String[] lines, boolean keepWithPrevious) {
        boolean res = false;
        int i=0;
        if (this.freeLines() >= lines.length){
            for (i=0; i < this.rows; i ++){
                this.text.add(lines[i]);
            }
            res = true;
        }
        if (this.text.size() == this.rows){
            // then the page is really full
            this.pageFull = true;
        }
        return res;
    }
    
    /**
     * set the pageNumber to required value
     *@param n - Required page number
     *
     **/
    
    public void setPageNumber(int n){
        this.pageNumber = n % 1000;
        String nums="A B C D E F G H I";
        StringTokenizer s = new StringTokenizer(nums);
        Vector <String> numV = new Vector<String>(10);
        int i=0;
        while(s.hasMoreElements()){
            numV.add(s.nextToken());
        }
        String pnum="#";
        String ns = Integer.toString(this.pageNumber);
        for (i=0; i <ns.length(); i++){
            int digit = Integer.parseInt(ns.substring(i,i+1));
            pnum += numV.get(digit - 1);
        }
        // Add this to end of header text,
        //this.headerText
        String pn =new String();
        for (i =0; i< this.PAGENUMBERSPACE; i++){
            pn += " ";
        }
        pn += pnum; // add the actual page number
        int startat= this.cols - this.PAGENUMBERSPACE;
        String head=this.headerText.substring(0, startat - 1); // Header text
        head +=pn; // add the pagenumber
        this.headerText = head;
        //System.err.println(" Header is " + head);
        
    }
    
    /**
     * get the current page content. *
     *
     * @return array of strings which are the page
     */
    public String[] getPage() {
        int i = 0;
        String[] res = new String[this.rows];
        if (this.hasHeader){
            res[0] = this.headerText;
            i = 1;
        }
        
        for ( ; i < this.text.size(); i++){
            res[i]=this.text.get(i);
            if (res[i] == null)
                res[i] ="";
        }
        return res;
    }
    
    /**
     * Determine the number of free lines on current page
     *
     * @return number of lines available for writing on this page
     */
    private  int freeLines() {
        // System.err.println(this.rows - this.text.size()+" free lines");
        return this.rows - this.text.size();
        
        
    }
    
    /**
     * Clear out the page contents. -  Clears the page content whilst retaining page size
     * information and retaining header information.
     */
    public void newPage() {
        this.text.clear();
        if (this.hasHeader){
            this.text.add(this.headerText);
        }
    }
    
    /**
     * Add a {@link org.dpawson.format.Paragraph Paragraph} to the page
     *
     * @param p
     *            paragraph to be added
     * @return true implies para was added.
     */
    public boolean addPara(Paragraph p) {
        boolean res = false;
        ArrayList<String> lns = p.paraToBlock(p.getContents());
        if (this.freeLines() >= lns.size()){
            for (int i=0; i< lns.size(); i++)
                this.text.add(lns.get(i));
            res = true; // added
        } else{
            res= false;
        }
        if (this.text.size() == this.rows){
            // then the page is really full
            this.pageFull = true;
        }
        return res;
    }
    
    /**
     * Test a paragraph for suitability for the page. Checks the row and column
     * count for a match with this page specification, {@link #cols } and
     * {@link #rows}
     *
     * @param p
     *            {@link org.dpawson.format.Paragraph Paragraph} to be checked
     * @return true indicates a match with current pages properties - otherwise false.
     */
    public boolean checkPara(Paragraph p) {
        boolean res = false;
        if (p.getColCount() <= this.cols ){
            if (p.GetRowCount() <= (this.rows - this.text.size())){
                res = true;
            }
        }
        return res;
    }
    
    /**
     * Test harness for Page object
     * @param args
     */
//@TODO FIXME! complete the testing
    public static void main(String [] args){
        System.out.println("Test Harness for Page object");
        int linesPerPage = 20;
        int colsPerLine = 36;
        String hdrText="Header text which is too long to fit on the line";
        String wkg ="";
        boolean res=false;
        
        
        
        Page pg = new Page(linesPerPage,colsPerLine, hdrText,987);
        //pg.addHeader(hdrText, true);
        //pg.setPageNumber(9);
        
        Paragraph p = new Paragraph(colsPerLine);
        String t ="A nominally long string which is exactly xxxxxxxxxx 64 chars long";
        wkg=p.prPara(t, 1,3);
        res=pg.addPara(p);
        
        System.out.println("\n\n************ Build a valid page ************\n");
        pg.newPage();
        while (pg.addPara(p)  ){
        }
        
        
        System.out.println("Done. Page is \n\n ");
        String [] thisPage = pg.getPage();
        for (int i=0; i < thisPage.length; i++){
            System.out.println(thisPage[i]);
        }
        
        // Test out Localizer for I18N
        //pg = new Page(50,colsPerLine); // invalid linesPerPage
        pg = new Page(linesPerPage,60); // invalid linesPerPage
        
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


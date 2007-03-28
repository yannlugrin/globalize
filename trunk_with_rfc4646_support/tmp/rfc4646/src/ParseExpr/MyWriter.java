/*
 * MyWriter.java
 *
 * Created on 21 September 2006, 09:38
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ParseExpr;

import java.io.*;

/**
 * myWriter acts on all io for the program
 * *This module, both source code and documentation, comes with NO WARRANTY.
 */
class MyWriter {
    
        /*
         * output object. used to put output to the output stream
         *
         */
    // private FileOutputStream output;
	
	/**
	 * BufferedWriter, the actual output used
	 */
    private BufferedWriter output;
    
    /**
     * Output stream name
     */
    public String stream="";
    
    /**
     *Provide getter for output stream - to allow name access
     **/
    private File opStream=null;
    
    /**
     * Open the output file.
     *
     * @param fName output file name to be written to.
     */
    public void openFile(String fName) {
        File opFile = new File(fName);
        
        if (opFile == null || opFile.getName().equals("")) {
            this.stream="console";
            //System.err.println("\nOpening console for output\n");
        } else {
            this.stream="file";
            // Open the file
            try {
                output = new BufferedWriter(new OutputStreamWriter(
                        new FileOutputStream(opFile), "UTF-8"));
            } catch (IOException e) {
                System.err.println("Error opening file" + e);
            }
        }
        this.opStream = opFile;
        
    }
    
    /**
     *get the output details
     *@return File which is the output stream
     **/
    public File getOutputStream(){
        return this.opStream;
    }
    
    /**
     * Quit - Close the output file 
     *
     */
    public void quit() {
        closeFile();
        
    }
    
    /**
     * Close the output file.
     *
     */
    private void closeFile() {
        if (output == null) {
            return;
        } else {
            try {
                output.close();
            } catch (IOException ex) {
                System.err.println("Error closing file");
            }
        }
    }
    
    /**
     * write to the output stream
     *
     * @param s
     *            string to be written
     */
    public void write(String s) {
        if (output == null) {
            System.out.print(s);
            
        } else {
                        /*
                         * byte[] bytes=null; bytes = s.getBytes(); try {
                         * output.write(bytes); output.flush(); }catch(java.io.IOException
                         * e) { System.err.println("svgOutput: IO exception" );
                         * System.exit(1); }
                         */
            try {
                output.write(s);
            } catch (java.io.IOException e) {
                System.err.println("myWriter.write: IO exception");
                System.exit(1);
                
            }
        }
        
    }// end of writer
    
        /*
         * write to the output stream
         * @param s - String to be written
         */
    public void writeln(String s) {
        if (output == null) {
            System.out.println(s);
            
        } else {
            String str = s+"\n";
            try {
                output.write(str);
                output.flush();
            } catch (java.io.IOException e) {
                System.err.println("myWriter.writeln: IO exception");
                System.exit(1);
            }
        }
        
    }// end of writer
    

}
/**
 * Copyright (C) 2006  Dave Pawson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.

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

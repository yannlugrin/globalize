/*
 * AnalysisResult.java
 *
 * Created on 27 September 2006, 08:56
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.util;

/**
 * The result of an analysis of a piece of text. Type returned as {@link org.dpawson.util.Modes mode}
 * and length of match held in {@link #length}
 * @author DPawson
 */
public class AnalysisResult{
	/**
	 *  The returned {@link org.dpawson.util.Modes mode}, set to {@link Modes#DEFAULT DEFAULT} by default
	 */
    public  Modes mode=Modes.DEFAULT;
    
    /**
     * The length of the match found in characters
     * 
     */
    public  int length = 0;
 
  }
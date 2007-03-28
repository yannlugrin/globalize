/*
 * Rule.java
 *
 * Created on 20 September 2006, 12:31
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.impl;/*
 * Rule.java
*
* Created on 20 September 2006, 12:31
*
* To change this template, choose Tools | Template Manager
* and open the template in the editor.
*/


/*
* Rule.java
*
* Created on 20 Sept 06
*
* To change this template, choose Tools | Template Manager
* and open the template in the editor.
*/

/**
*
* @author dpawson
*/
public class Rule {
   
   /** Creates a new instance of rule
    * Only called from @see org.dpawson.text2braille#text2brailleInit
    * 
    **/
   public Rule() {
   }
   /**
    * regex to match prefix to actual string
    */
    String LEFTCONTEXT=null;
    /**
     * Actual string being matched, not a regex, despite its name
     */
    String INPUT=null;
    /**
     * RightRegex is the postfix regex to the matched one
     */
    String RIGHTCONTEXT=null;
    /**
     * Contraction to apply when a match is found
     */
    String OUTPUT=null;
    /**
     * Source character count to 'shift out' after a match
     */
    int SHIFT=0;

   /**
    *Calculated rule number
    **/
    int RULENUMBER=0;
   
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

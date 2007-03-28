/*
 * BrailleEngineFactory.java
 *
 * Created on 18 September 2006, 14:49
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.impl;

/**
 *
 * @author dpawson
 */
public class BrailleEngineFactory {
    
    /** Creates a new instance of BrailleEngineFactory */
    public BrailleEngineFactory() {
    }
    
    /**
     * Instantiate a {@link org.dpawson.impl.BrailleTable BrailleTable} according to the language specfied in lang - Defaults to lang='en-GB'
     * @param lang  
     * @return {@link org.dpawson.impl.BrailleTable BrailleTable } 
     */
    public BrailleTable createBrailleTable(String lang){
        BrailleTable res=null;
        //System.out.println("BrailleEngineFactory.createBrailleEngine called");
        if (lang.equals("en")){
            res = new ENBrailleTable();
        }else if (lang.equals("se")){
            res=new SEBrailleTable();
        } else if (lang.equals("XX")){
            res = new XXBrailleTable();
        } else {
        	res = new ENBrailleTable(); // Default
        }
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
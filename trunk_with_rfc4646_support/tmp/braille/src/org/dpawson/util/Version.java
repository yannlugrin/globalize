/*
 * Version.java
 *
 * Created on 21 September 2006, 09:46
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.util;

/*
 * Version.java
 *
 * Created on 09 April 2006, 13:20
 */

/**
 *
 * @author dpawson
 */

/**
 * The Version class holds the text2braille version information.
 */
public class Version {
    public static String javaVersion = System.getProperty("java.version");
    public static boolean preJDK12 =
            javaVersion.startsWith("1.1") ||
            javaVersion.startsWith("1.0") ||
            javaVersion.startsWith("3.1.1 (Sun 1.1");   // special for IRIX 6.5 Java
    /**
     * Is this compiler prior to JDK 1.2?
     * @return tru if yes.
     */
    public static final boolean isPreJDK12() {
        return preJDK12;
    }
    
    /**
     *Returns the version of this program
     *@return Version number of the program
     */
    public final static String getVersion() {
        return "1.0.1";
    }
    
    
    /**
     *Returns the product name
     *
     */
    public static String getProductName() {
        return "text2braille " + getVersion() + " from Mark Frodsham, ported by Dave Pawson";
    }
    /**
     *Returns the website of the software
     *
     */
    public static String getWebSiteAddress() {
        return "http://www.dpawson.co.uk/braille/friday/";
    }
    
    /**
     *Get publication date
     *
     **/
    public static String getDate(){
        return "2006-09-07";
        
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






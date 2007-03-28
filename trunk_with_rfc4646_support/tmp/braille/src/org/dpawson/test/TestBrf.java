package org.dpawson.test;

/*
 * TestBrf.java
 *
 * Created on 21 September 2006, 09:49
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

/**
 * local imports
 */
import org.dpawson.format.*;
import org.dpawson.util.*;

/**
 * Class to test the formatter. Currently only tests the paragraph object
 *
 *  @author dpawson
 * 
 *
 */
public class TestBrf {
    
    
    /**
     *Constructor - Unused
     */
    public TestBrf() {
        
    }
    
    /**
     * Test the formatter
     * @param args args[2] can specify the output
     */
    public static void main(String[] args) {
        String input = "";
        String out = "";
        if (args.length > 1)
            out = args[2];
        // setup the tests
        
        Paragraph p = new Paragraph(30);
        Test test = new Test(p.getClass().getCanonicalName() + " version "
                + Page.Version, "");
        
        // Insert testing statements here
        //System.exit(2);
        
        input = "TheQuickBXownfoxJuXpsOver,ThXlazyDogXetcetcetc   ";
        out = p.prPara(input);
        Test.Assert("TheQuickBXownfoxJuXpsOver,\nThXlazyDogXetcetcetc   ", out);
        
        input = "1234567890123456789012345678901234567890";
        out = p.prPara(input);
        Test.Assert("12345678901234567890123456789\n01234567890", out);
        
        // 2
        input = "HA/E /AT$ PRIE/ /RET* /ORY /RIK+ FA/ /AFF E>NE/ <O/ DE/ROY]";
        out = p.prPara(input);
        Test.Assert("HA/E /AT$ PRIE/ /RET* /ORY \n/RIK+ FA/ "
                + "/AFF E>NE/ <O/ \nDE/ROY]", out);
        
        input = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        out = p.prPara(input, 2, 1); // invalid startIndent
        Test.Assert("ABCDEFGHIJKLMNOPQRSTUVWXYZ123\n 4567890", out);
        
        // 4
        input = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        out = p.prPara(input, 5, 2); // invalid endIndent
        Test.Assert("     ABCDEFGHIJKLMNOPQRSTUVWXYZ123" +
                "\n4567890", out);
        
        input = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        out = p.prPara(input, 3, 5);
        Test.Assert("   ABCDEFGHIJKLMNOPQRSTUVWXYZ123\n     4567890", out);
        // 6
        out = p.prPara(input, 1, 6);
        Test.Assert(" ABCDEFGHIJKLMNOPQRSTUVWXYZ123\n4567890", out);
        
        //7
        input = "The cat sat on the mat. The cat sat on the mat";
        out = p.prPara(input, 1, 3);
        Test.Assert(" The cat sat on the mat. The \n   cat sat on the mat", out);
        
        input="                16 Prepended whitespace";
        out = p.prPara(input);
        Test.Assert("                16 Prepended \nwhitespace", out);
        
        
        input="16 midway                whitespace";
        out = p.prPara(input);
        Test.Assert("16 midway                \nwhitespace", out);
        //10
        input="16 appended whitespace                ";
        out = p.prPara(input);
        Test.Assert("16 appended whitespace       \n         ", out);
        
        
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
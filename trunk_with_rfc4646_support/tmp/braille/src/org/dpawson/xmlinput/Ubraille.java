/*
 * Ubraille.java
 *
 * Created on 11 October 2006, 11:49
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.xmlinput;
import org.xml.sax.SAXException;

import java.io.IOException;
import org.dpawson.format.Page;
import org.dpawson.format.Paragraph;
import org.xml.sax.*;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;
/**
 *
 * @author dpawson
 */
public class Ubraille {
    
    /** Creates a new instance of ubraille */
    public Ubraille() {
    }
    
    public static void main(String [] argv){
        if(argv.length  < 1){
            System.err.println("Usage: java org.dpawson.xmlinput <xmlFile>");
            System.exit(2);
        }
        String selectedParser="org.apache.xerces.parsers.SAXParser";
        
        XMLReader       producer=null;
        DefaultHandler  consumer=null;
        
        // Get an instance of the default XML parser class
        int x=0;
        try {
            producer = XMLReaderFactory.createXMLReader(selectedParser);
            try {
                producer.setFeature("http://xml.org/sax/features/namespace-prefixes", true);
                producer.setFeature("http://xml.org/sax/features/namespaces", true);
            } catch (SAXException e) {
                System.err.println("Cannot activate ns prefixes.");
            }
        } catch (SAXException e) {
            System.err.println(
                    "Can't get parser, check configuration: "
                    + e.getMessage());
            return;
        }
        
        // set up the consumer
        
        // Get a consumer for all the parser events
        consumer = new Handler();
        
        // Connect the most important standard handler
        producer.setContentHandler(consumer);
        
        // Arrange error handling
        //@TODO Set up a discrete error handler.

        producer.setErrorHandler(consumer);
        

            
        // Set up the formatter
        //Page(int linesPerPage, int colsPerLine, String headerText, int pageNumber)
        int rows =28;
        int cols =40 ;
        Page pg = new Page(rows,cols,"A simple header ",1);
        
        Paragraph para = new Paragraph(cols);
        
        
        
        
        // Do the parse!
        try {
            producer.parse(argv [0]);
        } catch(java.io.FileNotFoundException e){
            System.err.println("Input XML file not found - "+argv[0]+"\n" + e.toString());
            
        } catch (IOException e) {
            System.err.println("I/O error: "+ e.toString());
            e.printStackTrace();
        } catch (SAXException e) {
            System.err.println("Parsing error: "+ e.toString());
            e.printStackTrace();
            
        }
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
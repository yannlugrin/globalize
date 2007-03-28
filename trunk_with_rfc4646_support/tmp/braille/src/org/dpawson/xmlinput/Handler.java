/*
 * Handler.java
 *
 * Created on 11 October 2006, 11:47
 *
* Manage the XML input using a SAX2 parser. requires sax2.jar and xercesImpl.jar
 */
package org.dpawson.xmlinput;


import org.dpawson.impl.BrailleEngineFactory;
import org.dpawson.impl.BrailleTable;
import org.dpawson.impl.TextToBraille;

import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Stack;
import java.util.StringTokenizer;
import java.util.Vector;
import org.xml.sax.Locator;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * Handler manages the elements and attributes of an XML input document valid to the xbrl.rng schema
 * @author dpawson
 */
public class Handler extends DefaultHandler {
    
    private static final String defaultNS="http://www.dpawson.co.uk/ns#";
    
    // Paragraph types
    private static final int DEFAULTPARA  = 0;
    private static final int INDENTPARA   = 1;
    private static final int PRESERVEPARA = 2;
    
    
    private Stack	<String>	stack;
    
    // hashmap of attributes, keyed off element stack depth
    private HashMap <Integer, Attributes>attrStore = null;
    
    // Source document locator
    private Locator		locator;
    
    // File name of source
    private String sourceUri ="";
    
    private int pageNumber=1;
    
    // Translator
    TextToBraille t2=null;
    
    
    int grade = 2;
    
    /**
     *Stringbuffer used to hold input characters
     **/
    StringBuffer buff =null;
    
    /**
     *map of namespace to prefix used
     **/
    private HashMap <String, String>namespaces=null;
    
    
    /**
     * Constructor - set up the stack
     *
     **/
    public Handler(){
        stack = new Stack <String>();
        attrStore = new HashMap<Integer, Attributes>();
        namespaces = new HashMap <String ,String>();
        buff = new StringBuffer();
        
        // Create the engine
        
        
        BrailleEngineFactory factory = new BrailleEngineFactory();
        BrailleTable table = factory.createBrailleTable("en");
        t2 = new TextToBraille(table); // t1.getTranslator();

    }
    
    /**
     * Set up the Locator for access to the document name
     *
     **/
    public void setDocumentLocator(Locator l) {
        locator = l; }
    
    
    /**
     *Determine the name of the element on the top of the stack
     * @return Element name
     **/
    private String getCurrentElementName() {
        return (String) stack.peek(); }
    
    /**
     *First event - the root of the document, set up the source URI
     *
     **/
    public void startDocument() throws SAXException {
        if (locator != null)
            sourceUri = locator.getSystemId();
        
        String name = locator.getSystemId();
        System.out.println(" Processing "+ name);
        
    }
    
    
    /**
     *Debug - Print out the element name
     * @param namespace
     * @param name
     *
     **/
    private void dumpEl(String ns, String localName){
        
        int nscount = namespaces.size();
        String nm =localName;
        System.out.print(locator.getLineNumber()+"\t"+ nm);
        if (!ns.equals("")){
            if (namespaces.containsValue(ns)){
                nm=namespaces.get(ns)+":" + localName;
            }else {
                namespaces.put("ns"+Integer.toString(nscount+1),ns); //@TODO find a way to get prefix
                nm=   "ns"+Integer.toString(nscount);
            }
            
        }
        
    }
    
    /**
     *Debug - Print out  the attributes
     * @param attrs - attributes on the current element
     *
     **/
//    private void prAttrs(Attributes attrs){
//        String nm="";
//        String value="";
//        System.err.println("Stack depth is "+ stack.size());
//        attrStore.put(stack.size(), attrs);
//        for (int i=0; i< attrs.getLength(); i++){
//            nm = attrs.getQName(i);
//            value = attrs.getValue(nm);
//            System.out.println("\t\t@"+nm+" = " + value);
//        }
//    }
    
    
    
    
    
    
    /**
     * Process elements
     * @param namespace of the current element
     * @param localName local-name() of the current element
     * @param qname Qname of the element
     * @param attrs - the attributes of the current element
     *
     **/
    public void startElement(
            String		namespace,
            String		localName,
            String		qname,
            Attributes	attrs
            ) throws SAXException {
        // Preserve the element name on the stack
        stack.push(qname);
        //dumpEl(namespace, localName);
        
        if (attrs.getLength() >0){
            attrStore.put(stack.size(),attrs); // store the attributes
            //prAttrs(attrs);
        }else {
            System.out.println();
        }
        
    }
    
    
    /**
     * End of an element event handler
     * @param namespace of the element
     * @param localName local-name() of the element
     * @param name name of the element
     *
     **/
    public void endElement(
            String		namespace,
            String		localName,
            String		name
            ) throws SAXException {
        //System.out.println("</" + name+">");
        
        // pop name from stack if matching
        //@TODO CHECK this logic
        
        if (namespace.equals(defaultNS)){
            if (localName.equals("para")){
                prPara();
                buff.delete(0,buff.length() );
            }
            
        }
        if (name.equals(stack.peek())){
            // remove attributes from store, and pop the stack
            attrStore.remove(attrStore.get(stack.size()));
            stack.pop();
            
        }
    }
    
    /**
     *Process paragraph content
     *Called when a start element event is for a para element
     *Element name is top of stack
     **/
    void prPara(){
        //Retrieve the para content
        String text = buff.toString();
        //System.err.println("Element: "+ stack.peek());
        
        
        
        if (attrStore.get(stack.size()) != null){
            Attributes attrs = attrStore.get(stack.size());
            // see what type it is
            int type = analysePara(attrs);
            switch (type){
                case DEFAULTPARA: {
                    // process
                    System.out.println("Input["+ text+"]");
                    System.out.println("\"" + t2.Translate(text,2) + "\"");
                    break;
                }
                case INDENTPARA: {
                    // process
                    System.out.println("Input["+ text+"]");
                    System.out.println("\"" + t2.Translate(text,2) + "\"");
                    break;
                }
                case PRESERVEPARA:{
                    // process
                    System.err.println("\t****We don't process ws preserved paras!");
                    break;
                }
                default: {
                    // Cannot happen
                    System.err.println("Invalid attribute type "+ type +"\n Quitting");
                    System.exit(2);
                }
            }
            
        }
    }
    
    
    /**
     *Determine the type of para from the attributes
     * One from indented, default or preservespace
     **/
    private int analysePara(Attributes attrs){
        int res=0;
        Vector <String> names=new Vector<String>(attrs.getLength());
        for (int i=0; i< attrs.getLength(); i++){
            names.add(attrs.getQName(i));
        }
        if (names.contains("xml:space")){
            String value = attrs.getValue("xml:space");
            if (value.equals("preserve")){
                res = this.PRESERVEPARA;
            } else {
                // treat as default
                res = this.DEFAULTPARA;
            }
        }  else if (names.contains("s")){
            res = this.INDENTPARA;
        }  else if (names.size() == 0){
            res = this.DEFAULTPARA;
        }
        return res;
    }
    
    
    
    
    
    /**
     *Capture character data
     * @param ch - Array of char which is the text
     * @param start - start position in ch[]
     * @param length - Number of usable characters
     **/
    public void characters(char[] ch,
            int start,
            int length) {
        if (stack.peek().equals("para")){
            buff.append(ch,start,length); // append to buffer for para
        }
    }
    
    
    

    
    
    
    /**
     *
     *
     **/
    public void endDocument(){
        System.out.println("Finished");
        Collection c = namespaces.values();
        Iterator i = c.iterator();
        while (i.hasNext())
            System.out.println("ns "+ i.next());
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
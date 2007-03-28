/*
 * Localizer.java
 *
 * Created on 17 October 2006, 08:25
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.util;

// Original thanks to JC, package com.thaiopensource.util;

import java.util.ResourceBundle;
import java.text.MessageFormat;

public class Localizer {
    private final Class cls;
    private ResourceBundle bundle;
    
    public Localizer(Class cls) {
        this.cls = cls;
    }
    
    public String message(String key) {
        return MessageFormat.format(getBundle().getString(key), new Object[]{});
    }
    
    public String message(String key, Object arg) {
        return MessageFormat.format(getBundle().getString(key),
                new Object[]{arg});
    }
    
    public String message(String key, Object arg1, Object arg2) {
        return MessageFormat.format(getBundle().getString(key),
                new Object[]{arg1, arg2});
    }
    
    public String message(String key, Object[] args) {
        return MessageFormat.format(getBundle().getString(key), args);
    }
    
    /**
     *Retrieve the bundle for the class set in the constructor
     *@return an appropriate bundle, or quit
     *      Works with messages in file Messages[_lang].properties in classpath/s
     *  with all . replaced by /
     *  E.g. org.dpawson.format messages are in
     *  org/dpawson/format/resources as file Messages.properties, Messages_fr.properties etc.
     *  e.g. org/dpawson/resources/Messages_en_UK.properties
     *  The baseName is always Messages.properties
     *  Note. This directory will require creating in the distribution.
     *   for  testing it is located in the resources directory, with class file structure
     *
     ***/
    private ResourceBundle getBundle() {
        if (bundle == null){
            String s = cls.getName();
            int i = s.lastIndexOf('.');
            if (i > 0)
                s = s.substring(0, i + 1);
            else
                s = "";
            //System.err.println("Localizer: bundle is ["+ s +"resources.Messages]");
            
            try{
                bundle = ResourceBundle.getBundle(s + "resources.Messages");
            } catch(java.util.MissingResourceException err){
                System.err.println("Missing bundle "+ err.toString());
                System.exit(2);
            }
            // Works. with Messages_en_UK.properties in classpath
            //bundle = ResourceBundle.getBundle(s + "Messages");
        }
        return bundle;
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
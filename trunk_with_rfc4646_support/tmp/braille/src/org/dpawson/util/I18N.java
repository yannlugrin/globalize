/*
 * I18N.java
 *
 * Created on 17 October 2006, 08:30
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.util;

import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

/**
 *
 * @author dpawson
 */
public class I18N {
    
    /**
     * Creates a new instance of I18N
     */
    public I18N() {
    }
    
    
    /**
     * Retrieve a message from a specific bundle in default locale
     * @param bundle - bundle to seek
     * @param key - sought key.
     *
     */
    public void message(String bundle, String key) {
        ResourceBundle bun = this.getBundle(bundle, Locale.getDefault());
        
        // System.out.println("Retrieving bundle for "+
        //locale.getLanguage()+
        //    locale.getCountry());
        try {
            System.out.println(bun.getString(key));
        } catch (java.util.MissingResourceException err) {
            System.err.println("generics.i18n: Resource error. Missing key "
                    + err.getKey());
            System.err.println("Using "
                    + Locale.getDefault().getDisplayLanguage());
        }
    }
    
    
    /**
     * Retrieve a message from a specific bundle in a specific locale
     * @param bundle - bundle to seek
     * @param locale - Specified locale to use, could be either simply the
     * language or language, country and variant
     * @param key - sought key.
     *
     */
    public void message(String bundle, Locale locale, String key) {
        ResourceBundle bun = getBundle(bundle, locale);
        
        System.out.println("Retrieving bundle for " + locale.getLanguage()
        + locale.getCountry());
        
        // ResourceBundle bun = ResourceBundle.getBundle(bundle, locale);
        System.out.println(bun.getString(key));
    }
    /**
     *
     *
     * The algorithm used by getBundle( ) is based on appending
     * the country and language codes of the requested Locale to the name of the resource.
     * Specifically, it searches for resources in this order:
     *
     * name_language_country_variant
     * name_language_country
     * name_language
     * name
     * name_default-language_default-country_default-variant
     * name_default-language_default-country
     * name_default-language
     *
     * Property files must be in runtime classpath.
     * E.g. bundle_lang_Country.properties
     *      bundle_lang.properties
     *      bundle.properties
     *as a hiearchy
     *
     *
     *
     */
    public ResourceBundle getBundle(String bundle, Locale locale) {
        ResourceBundle res = null;
        
        try {
            res = ResourceBundle.getBundle(bundle, locale);
        } catch (MissingResourceException err) {
            System.err.println("Unable to find default resource bundle.\n "
                    + err.toString() + " Quitting");
            System.exit(2);
        }
        
        return res;
    }
    
    public static void main(String[] args) {
        
        // Locale l = Locale.ITALIAN;
        Locale l = Locale.getDefault();
        
        System.out.println("Working in Locale " + l.getLanguage() + "-"
                + l.getCountry());
        
        // System.out.println("******");
        // System.out.println(l.getLanguage(  ));           // it
        // System.out.println(l.getDisplayLanguage(  ));    // Italian
        
        I18N m = new I18N();
        
        
        
        Localizer loc = new Localizer(m.getClass());
        String msg = loc.message("simple");
        System.err.println(msg);
        System.exit(2);
        
        
        m.message("Errors", l, "NoRulesFile");
        m.message("Errors", l, "InvalidRulesFile");
        
        // Change Locale.
        l = Locale.CANADA_FRENCH;
        System.out.println("\t\tWorking in Locale " +
                l.getLanguage() +
                "-" +
                l.getCountry());
        m.message("Errors", l, "NoRulesFile");
        
        // Get default error message.
        m.message("Errors", "NonWellFormedRulesFile");
        
        // Output an error using default locale
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

/*
 * Modes.java
 *
 * Created on 21 September 2006, 09:43
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package org.dpawson.util;

import java.util.*;

/**
 * Modes class implements an enumeration of modes, one from
 * {@link #ACRONYM ACRONYM}, {@link #DATE DATE} or {@link #DEFAULT DEFAULT}.
 * Based on typesafe enum pattern, see 
 * {@link <a href="http://java.sun.com/developer/Books/shiftintojava/page1.html"> Sun</a>}
 *  @author dpawson
 * 
 */
public final class Modes {

	/**
	 * Id of class
	 */
	private String id;

	/**
	 * Upper bound of list
	 */
	public final int ord;

	/**
	 * Previous mode
	 */
	private Modes prev;

	/**
	 * Next mode
	 */
	private Modes next;

	/**
	 * Upper limit count of items
	 */
	private static int upperBound = 0;

	/**
	 * First item
	 */
	private static Modes first = null;

	/**
	 * Last item
	 */
	private static Modes last = null;

	/**
	 * Constructor
	 * 
	 * @param anID -
	 *            ident (which is the type of mode)
	 */
	private Modes(String anID) {
		this.id = anID;
		this.ord = upperBound++;
		if (first == null)
			first = this;
		if (last != null) {
			this.prev = last;
			last.next = this;
		}
		last = this;
	}

	/**
	 * Enumeration over modes
	 * 
	 * @return Enumeration of modes
	 */
	public static Enumeration elements() {
		return new Enumeration() {
			private Modes curr = first;

			public boolean hasMoreElements() {
				return curr != null;
			}

			public Object nextElement() {
				Modes c = curr;
				curr = curr.next();
				return c;
			}
		};
	}

	/**
	 * Printable ident
	 * 
	 * @return string id
	 */
	public String toString() {
		return this.id;
	}

	/**
	 * Size of enumeration
	 * 
	 * @return int size
	 */
	public static int size() {
		return upperBound;
	}

	/**
	 * First mode
	 * 
	 * @return first mode
	 */
	public static Modes first() {
		return first;
	}

	/**
	 * Last mode
	 * 
	 * @return last mode
	 */
	public static Modes last() {
		return last;
	}

	/**
	 * previous mode of an enum
	 * 
	 * @return previous mode
	 */
	public Modes prev() {
		return this.prev;
	}

	/**
	 * Next mode of enum
	 * 
	 * @return next mode in the enumeration
	 */
	public Modes next() {
		return this.next;
	}

	/**
	 * Access to modes.
	 * Return a new {@link #ACRONYM ACRONYM} mode
	 */
	public static final Modes ACRONYM = new Modes("Acronym");

	/**
	 * Return a new {@link #DATE DATE} mode
	 */
	public static final Modes DATE = new Modes("Date");

	/**
	 * Return a new {@link #DEFAULT DEFAULT } mode
	 */
	public static final Modes POSTCODE = new Modes("Postcode");

	/**
	 * Return a new {@link #DEFAULT DEFAULT} mode
	 */
	public static final Modes DEFAULT = new Modes("Default");
        
        /**
         *Return a new {@link #ROMANNUMERAL ROMANNUMERAL} mode
         */
        public static final Modes ROMANNUMERAL = new Modes("RomanNumeral");

}
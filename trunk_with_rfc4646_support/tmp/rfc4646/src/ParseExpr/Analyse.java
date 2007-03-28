/*
 * Analyse.java
 *
 * Created on 05 November 2006, 08:18
 *
 *
 */

package ParseExpr;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileReader;
import java.util.regex.*;
import java.util.StringTokenizer;

/**
 * @author dpawson
 *
 */
public class Analyse {
  
        /*
         * # # rfc4646.txt regexing. # src
         * http://unicode.org/cldr/data/tools/java/org/unicode/cldr/util/data/langtagRegex.txt #
         * and
         * http://unicode.org/cldr/data/tools/java/org/unicode/cldr/util/data/langtagTest.txt
         * is the test code. # And thread starting at
         * http://www1.ietf.org/mail-archive/web/ltru/current/msg05589.html # Martin
         * Duerst calls out a mistake. #There"s a mistake in the regex, from the
         * underlying #langtagRegex.txt, that allows zh-zh-cmn-Hans. # #Regards,
         * Martin.
         */
  
  String prog = "rfc4646";
  
  static String version = "1.02";
  static String date ="2006-11-07T20:50:03Z";
  
  int debug = 5;
  
        /*
         * # #From http://www1.ietf.org/mail-archive/web/ltru/current/msg05625.html #
         * I couldn"t make this work. Too big to debug. #
         * Is it a waste of time?
         */
  String patt = "((?: [a-z A-Z]{2,3} (?: [-] [a-z A-Z]{3} ){0,3} | [a-z A-Z]{4,8} ))(?: [-] ((?: [a-z A-Z]{4} )) )?(?: [-] ((?: [a-z A-Z]{2} | [0-9]{3} )) )?(?: [-] ((?: (?: [0-9] [a-z A-Z 0-9]{3} | [a-z A-Z 0-9]{5,8} ) (?: [-] (?: [0-9] [a-z A-Z 0-9]{3} | [a-z A-Z 0-9]{5,8} ) )* )) )?(?: [-] ((?: (?: [a-w y-z A-W Y-Z] (?: [-] [a-z A-Z 0-9]{2,8} )+ ) (?: [-] (?: [a-w y-z A-W Y-Z] (?: [-] [a-z A-Z 0-9]{2,8} )+ ) )* )) )?(?: [-] ((?: [xX] (?: [-] [a-z A-Z 0-9]{1,8} )+ )) )?| ( (?i) art [-] lojban| cel [-] gaulish| en [-] (?: boont | GB [-] oed | scouse )| i [-] (?: ami | bnn | default | enochian | hak | klingon | lux | mingo | navajo | pwn | tao | tay | tsu )| no [-] (?: bok | nyn)| sgn [-] (?: BE [-] fr | BE [-] nl | CH [-] de)| zh [-] (?: cmn | zh [-] cmn [-] Hans | cmn [-] Hant | gan | guoyu | hakka | min | min [-] nan | wuu | xiang | yue))| ((?: [xX] (?: [-] [a-z A-Z 0-9]{1,8} )+ )) ";
  
        /*
         * # #From
         * http://unicode.org/cldr/data/tools/java/org/unicode/cldr/util/data/langtagRegex.txt #
         */
  
  /**
   *ALPHA
   **/
  public static String alpha = "[a-zA-Z]"; // ALPHA
  
  /**
   *DIGIT
   **/
  public static String digit = "[0-9]"; // DIGIT
  
  /**
   *ALPHADIGIT
   **/
  public static String alphanum = "[a-zA-Z0-9]"; // ALPHA / DIGIT
  
  /**
   *singleton
   **/
  public static String x = "[xX]"; // private use singleton
  
  /**
   * Other singleton!
   **/
  public  static String singleton = "[a-wy-zA-WY-Z0-9]"; // other singleton
  
  /**
   *Group separator
   **/
  public static String s = "[-]"; // separator -- lenient parsers will use
  
  // [-_]
  
        /*
         * # Now do the components. The structure is slightly different to allow #
         * for capturing the right components. The "?:" can be deleted if # someone
         * doesn"t care about capturing.
         *(-[a-z]{3}){0,3}
         */
  public static String extlang = "(" + s + alpha + "{3}){0,3}";// # *3("-" 3ALPHA);
  
  /**
   *basic language, e.g. en or english
   *(2*3ALPHA [ extlang ]) / 4ALPHA / 5*8ALPHA
   **/
  public static String language = "(" + alpha + "{4,8}|(" + alpha + "{2,3}(" + extlang+")*?))";// #
  
  
  
  
  
  /**
   * Script - 4ALPHA
   *
   *
   **/
  public static String script = "(" + alpha + "{4})";// # 4ALPHA
  
  /**
   * region - 2ALPHA                 ; ISO 3166 code
   *            / 3DIGIT                 ; UN M.49 code
   *e.g. AB, ab, 123
   **/
  public static String region = "(" + alpha + "{2}|" + digit + "{3})"; // # 2ALPHA / 3DIGIT
  
  /**
   * Helper for variant - which is 5*8alphanum  / (DIGIT 3alphanum)
   **/
  public static String variantSub = "(" + alphanum + "{5,8}|" + digit + alphanum + "{3})";// #
  
  /**
   *5*8alphanum  / (DIGIT 3alphanum)
   * E.g. abcde, 3abc, 3123
   **/
  public static String variant = "(" + variantSub + "(" + s + variantSub + ")*)";// #
  
  
  
  // (([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3})([-]([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3}))*)
  
  /**
   * Helper for extension which is singleton 1*("-" (2*8alphanum))
   **/
  public static String extensionSub =  "((" + s + alphanum + "{2,8})+)";// #
  
  /**
   * extension singleton 1*("-" (2*8alphanum))
   **/
  public static String extension = "("+singleton + "(" + extensionSub + ")+)";// #
  
  /**
   *privateuse - ("x"/"X") 1*("-" (1*8alphanum))
   **/
  public static String privateuse = "(" + x + "(" + s + alphanum + "{1,8})+)";// #
  
  
        /*
         * # Define certain grandfathered codes, since otherwise the regex is pretty
         * useless.
         * Since these are limited, this is safe even later changes to
         * the registry --
         * the only oddity is that it might change the type of the
         * tag, and thus the results from the capturing groups.
         * http://www.iana.org/assignments/language-subtag-registry
         * Note that these have
         * to be compared case insensitively, requiring (?i) below.
         *
         */
        /*
         * #grandfathered = """((?i) # en $s GB $s oed # | i $s (?: ami | bnn |
         * default | enochian | hak | klingon | lux | mingo | navajo | pwn | tao |
         * tay | tsu ) # | sgn $s (?: BE $s fr | BE $s nl | CH $s de))"""
         */
  
  
  
  /**
   *grandfathered - 1*3ALPHA 1*2("-" (2*8alphanum))
   *                   ; grandfathered registration
   *              ; Note: i is the only singleton
   *              ; that starts a grandfathered tag
   * 2006-11-07T20:50:03Z being sidelined. To be replaced by irregulars.
   **/
  public static String grandfathered = "(i([a-zA-Z]{1,2})?)("+s+"("+alphanum+"){2,8}){1,2}";
  
  
  /**
   *Irregulars - from http://www.iana.org/assignments/language-subtag-registry
   *Grandfathered tags are those registered under RFC 1766 or RFC 3066 whose
   * subtags are not all in the subtag registry.
   * There are two classes of grandfathered tags:
   * 1. Tags which are "well-formed" but for which some subtags are not
   * registered.
   * 2. Tags which are not well-formed and which are only valid as
   * grandfathered tags (which are called "irregular").
   **/
  public static String irregulars ="en-GB-oed|i-ami|i-bnn|i-default" +
    "|i-enochian|i-hak|i-klingon|i-lux|" +
    "|i-mingo|i-navajo|i-pwn|i-tao|i-tay|" +
    "i-tsu|sgn-BE-fr|sgn-BE-nl|sgn-CH-de";
  
  
  /**
   * langtag       = (language
   *               ["-" script]
   *               ["-" region]
   *               *("-" variant)
   *               *("-" extension)
   *               ["-" privateuse])
   **/
  public static String langtag="("+language+
    "(-"+script+")?"+
    "(-"+region+")?"+
    "(-"+variant +")?"+
    "(-"+extension + ")?"+
    "(-"+privateuse+")?)|"+irregulars;
  
  // expr=language
  // expr=script
  //String expr = language + s + variant;
  
  // ([a-zA-Z]{4,8}|([a-zA-Z]{2,3}([-][a-zA-Z]{3}){0,3}?))[-](([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3})([-]([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3}))*)
  String expr=language + "("+s+script+")?("+s+region+")?("+s+variant+")?";
  // expr=language+"("+s+script+")?"
  // expr=language+"("+s+script+")?("+s+region+")?("+s+variant+")?("+s+extension+")?("+s+privateuse+")?"
  // expr=root
  // expr=region
  // expr=variant
  // expr=privateuse
  // expr=grandfathered,re.IGNORECASE
  
  
  public Analyse(){
    
  }
  
  
  /**
   *retrieve version of this program
   **/
  public static String getVersion(){
    return version;
  }
  
  public void process(String expression) {
    Pattern p = Pattern.compile(expr);
    // System.out.println("Using regex " + expr);
    System.out.println(expression);
    Matcher m = p.matcher(expression);
    if (m.matches()) {
      System.out.println("Full Match on " + m.group());
    } else if (m.lookingAt()) {
      System.out.println("Partial match with: ");
      System.out.println(m.group());
    } else
      System.out.println("No match on "+ expression);
    if (debug > 4)
      split(expression);
    
  }
  
  public boolean analyse(String expression) {
    boolean res=false;
    
    Pattern p = Pattern.compile(expr);
    System.out.println("Using regex " + expr);
    System.out.println(expression);
    Matcher m = p.matcher(expression);
    if (m.matches()) {
      res= true;
    }
    if (debug > 4)
      split(expression);
    return res;
  }
  
  
  
  
  
  public void split(String exp) {
    int bit = 0;
    
    StringTokenizer st = new StringTokenizer(exp, "-");
    while (st.hasMoreTokens()) {
      // System.out.println(bit);
      checkAll(st.nextToken());
      bit += 1;
    }
  }
  
  /**
   *
   * @param expression
   */
  private void checkAll(String expression) {
    if (testType(expression, language))
      System.out.println("'" + expression + "' is a language ");
    if (testType(expression, language))
      System.out.println("'" + expression + "' is a language extension");
    if (testType(expression, script))
      System.out.println("'" + expression + "'' is a script");
    if (testType(expression, region))
      System.out.println("'" + expression + "'' is a region");
    if (testType(expression, variant))
      System.out.println("'" + expression + "'' is a variant");
    // if(isVariantSub(expression))
    // System.out.println( "'"+expression +"'' is a variantSub" );
    if (testType(expression, extension))
      System.out.println("'" + expression + "'' is an extension");
    if (testType(expression, extension))
      System.out.println("'" + expression + "'' is an ExtensionSub");
    if (testType(expression, privateuse))
      System.out.println("'" + expression + "'' is a privateuse");
    if (testType(expression, irregulars))
      System.out.println("'" + expression + "'' is an irregular");
    
  }
  
  
  
  
  
  
        /*
         * # #Helpers. Check if match
         * @param exp - expression to be tested
         * @param pattern - regex to use for test
         * @return true if match, false if not
         */
  
  public boolean testType(String exp, String pattern) {
    boolean res = false;
    Pattern p = Pattern.compile(pattern);
    Matcher m = p.matcher(exp);
    if (m.matches())
      res = true;
    return res;
  }
  
  /**
   *Program usage
   **/
  void usage() {
    System.out.println("Usage: java rfc4646 -e <langTag>");
    System.out.println("or, no parameter, runs internal tests");
  }
  
  public static void main(String[] args) {
    Analyse p = new Analyse();
    String expression = "";
    String infile = "";
    if (args.length < 2) {
      p.usage();
      System.exit(2);
    }
    System.out.println(p.prog + ". Version  " + " " + p.version);
    
    try {
      int i = 0;
      while (true) {
        if (i >= args.length)
          break;
        if (p.debug > 5)
          System.err.println("i: " + i + args.length + " args[i]="
            + args[i]);
        if (args[i].charAt(0) == '-') {
          if (args[i].equals("-t")) {
            // System.err.println(Version.getProductName());
            System.err.println("Java version "
              + System.getProperty("java.version"));
            i++;
          } else if (args[i].equals("-e")) {
            i++;
            expression = args[i++];
          } else if (args[i].equals("-f")) {
            i++;
            if (args.length < i + 1)
              p.usage();
            infile = args[i++];
          }
          
          else {
            p.usage();
            System.exit(2);
            
          }
          
        } else
          break;
      } // end while
      
    } catch (Exception err2) {
      err2.printStackTrace();
    }
    if (expression != "") {
      p.process(expression);
      System.exit(0);
    }
    
    if (infile == "") {
      System.err.println("");
    }
    BufferedReader inf = null;
    try {
      inf = new BufferedReader(new FileReader(infile));
      String line = "";
      while ((line = inf.readLine()) != null){
        p.process(line);
        
      }
      inf.close();
    } catch (java.io.IOException err) {
      System.err.println(err.toString());
      System.exit(2);
    }
    
                /*
                 * for line in open(infile): if line=="\n": System.out.println( elif
                 * line[0] == '#': System.out.println( line else: process(line[:-1])
                 */
    
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
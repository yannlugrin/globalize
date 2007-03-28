/*
 * TestAnalyse.java
 *
 * Created on 05 November 2006, 08:24
 *
 *
 */

package ParseExpr;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import ParseExpr.Analyse;

/**
 *This module, both source code and documentation, is in the Public Domain, and comes with NO WARRANTY.
 * @author dpawson
 */
public class TestAnalyse {
  
  /**
   *Usable Analyse instance
   **/
  private static Analyse t = null;
  /** Creates a new instance of TestAnalyse */
  public TestAnalyse() {
  }
  
  
  /**
   *Test language - language      = (2*3ALPHA [ extlang ]) ; shortest ISO 639 code
   *
   *            / 4ALPHA                 ; reserved for future use
   *            / 5*8ALPHA               ; registered language subtag
   * extlang       = *3("-" 3ALPHA)         ; reserved for future use
   **/
  public void testLanguage(){
    String []goodtests={"en","bra","abcD","abcDE","aBcDeFgH","abc-abc-abc-xyz","en-GBA"};
    String []badtests={"12","","aaaaaaaaa","eng-123"};
    System.err.println("language regex is "+ Analyse.language);
    run(goodtests, badtests, Analyse.language);
  }
  
  /**
   *test script regex
   *
   **/
  
  public void testScript(){
    String []goodtests={"ABCD","abcd"};
    String []badtests ={"abc","AB","a","1234"};
    System.err.println("Script regex is "+ Analyse.script);
    run(goodtests, badtests, Analyse.script);
  }
  
  
  /**
   *test region - 2ALPHA                 ; ISO 3166 code
   *            / 3DIGIT                 ; UN M.49 code
   **/
  public void testRegion(){
    String []goodtests={"ab","AB","aB","123"};
    String []badtests ={"ABC","a","12","1234"};
    System.err.println("region regex is "+ Analyse.region);
    run(goodtests, badtests, Analyse.region);
  }
  
  /**
   * test variant 5*8alphanum            ; registered variants
   *            / (DIGIT 3alphanum)
   **/
  public void testVariant(){
    String []goodtests={"abcde","abcdexyz","aBcDeFg","aBc12","3ABC","9abC"};
    String []badtests ={"AB","a","123","A234","a456"};
    System.err.println("variant regex is "+ Analyse.variant);
    run(goodtests, badtests, Analyse.variant);
  }
  
  /**
   * test variant singleton 1*("-" (2*8alphanum))
   **/
  public void testExtension(){
    String []goodtests={"a-ab","z-12","1-ab-12","M-aBc12","p-3ABC","b-9abCmnox","p-12-ab-cd","1-ab"};
    String []badtests ={"1-a","x-ab","c-1","a-A234-a","z-123456789"};
    System.err.println("extension regex is "+ Analyse.extension);
    run(goodtests, badtests, Analyse.extension);
  }
  
  /**
   * test  singleton  singleton     = %x41-57 / %x59-5A / %x61-77 / %x79-7A / DIGIT
   *            ; "a"-"w" / "y"-"z" / "A"-"W" / "Y"-"Z" / "0"-"9"
   *            ; Single letters: x/X is reserved for private use
   **/
  public void testSingleton(){
    String []goodtests={"a","m","1","9"};
    String []badtests ={"x","ab"};
    System.err.println("singleton regex is "+ Analyse.singleton);
    run(goodtests, badtests, Analyse.singleton);
  }
  
  /**
   * test  private use -   privateuse    = ("x"/"X") 1*("-" (1*8alphanum))
   **/
  public void testPrivateuse(){
    String []goodtests={"x-a","x-A","x-1","x-abcdefgh","X-12345678","x-ab-cd-ef"};
    String []badtests ={"x","a-","1-a","x-abcabcabc"};
    System.err.println("privateuse regex is "+ Analyse.privateuse);
    run(goodtests, badtests, Analyse.privateuse);
  }
  
  
  
  /**
   * test   grandfathered = 1*3ALPHA 1*2("-" (2*8alphanum))
   **/
  public void testGrandfathered(){
    String []goodtests={"iab-ab","iab-Ab","i-12","i-abcdefgh-12","i-12345678","iab-abc-def"};
    String []badtests ={"x","a-","1-a","x-abcabcabc"};
    System.err.println("grandfathered regex is "+ Analyse.grandfathered);
    run(goodtests, badtests, Analyse.grandfathered);
  }
  
  
  
  /**
   *test irregulars.
   **/
  public void testIrregulars(){
    String []goodtests={"en-GB-oed" , "i-ami" , "i-bnn" , "i-default"
             , "i-enochian" , "i-hak" , "i-klingon" , "i-lux"
             , "i-mingo" , "i-navajo" , "i-pwn" , "i-tao"
             , "i-tay" , "i-tsu" , "sgn-BE-fr" , "sgn-BE-nl"
             , "sgn-CH-de"};
    String []badtests ={"x","a-","1-a","x-abcabcabc"};
    System.err.println("irregular regex is "+ Analyse.irregulars);
    run(goodtests, badtests, Analyse.irregulars);
  }
  
  
  
  /**
   *test langtag
   **/
  public void testLangtag(){
    String []goodtests={"en-GBA","en-abcd","en-GBA-AB","en-3abc","en-a-ab","en-x-1","sgn-BE-fr"};
    String []badtests ={"abcd efgg"};
    System.err.println("langtag regex is "+ Analyse.langtag);
    run(goodtests, badtests, Analyse.langtag);
  }
  
  
  /**
   *Common test code
   **/
  private void run(String [] goodtests,String [] badtests, String regex){
    for (int i = 0; i < goodtests.length; i++){
      Pattern p = Pattern.compile(regex);
      Matcher m = p.matcher(goodtests[i]);
      if (!m.matches()){
        System.err.println("Fail on input ["+ goodtests[i]+"]");
      }
      Test.Assert(true,m.matches());
    }
    for (int i = 0; i < badtests.length; i++){
      Pattern p = Pattern.compile(regex);
      Matcher m = p.matcher(badtests[i]);
      if (m.matches()){
        System.err.println("Fail on input {"+ badtests[i]+"}");
      }
      Test.Assert(false,m.matches());
    }
  }
  
  
  
  
  
  
  public static void main(String [] args){
    t = new Analyse();
    TestAnalyse tests = new TestAnalyse();
    Test test = new Test(tests.getClass().getCanonicalName() + " version " +
      Analyse.getVersion(), "rfc4646.res.txt");
    System.out.println("Running. Results sent to " + test.getOutputPath());
    tests.testLanguage();
    tests.testScript();
    tests.testRegion();
    tests.testVariant();
    tests.testExtension();
    tests.testSingleton();
    tests.testPrivateuse();
    tests.testGrandfathered();
    tests.testLangtag();
    tests.testIrregulars();
    
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

#require 'rubygems'
#gem 'ruby-debug'
#require 'ruby-debug'
#Debugger.start

require File.dirname(__FILE__) + '/abstract_unit'

class StringTranslationTest < Test::Unit::TestCase

  def test_simple_string
    assert_equal "A string to be translated",   "A string to be translated".t
  end
  
  def test_simple_interpolated_string
    assert_equal 'This must be translated', "%s must be translated".t('This')    
  end
  
  def test_simple_pluralizable_string
    assert_equal 'They have 1 translation to do',  "They have %d translations to do".t(1)
    assert_equal 'They have 2 translations to do', "They have %d translations to do".t(2)    
  end
  
  def test_interpolated_and_pluralizable_string
    assert_equal "Tommy translated 1 translation",   "%s translated %d translations".t('Tommy',1)
    assert_equal "Tommy translated 2 translations",  "%s translated %d translations".t('Tommy',2)
    assert_equal "Tommy translated 1 translations",  "%s translated %d translations".t('Tommy','1')        
  end
  
  def test_multiple_interpolated_and_pluralizable_string
    assert_equal "Tommy & Joe translated 1 translation",  "%s & %s translated %d translations".t('Tommy','Joe',1)
    assert_equal "Tommy & Joe translated 2 translations", "%s & %s translated %d translations".t('Tommy','Joe',2)    
  end
  
  def test_error_string
    assert_equal "1 error prohibited this pizza from being saved",  "%d errors prohibited this %s from being saved".t(1,'pizza')
    assert_equal "2 errors prohibited this bagel from being saved", "%d errors prohibited this %s from being saved".t(2, 'bagel')    
  end
  
  def test_complex_verbal_pluralizable_string
    assert_equal "There is 1 translation to do",    "There are %d translations to do".t(1)
    assert_equal "There are 2 translations to do",  "There are %d translations to do".t(2)    
  end
  
  def test_complex_verbal_pluralizable_string_in_question_form
    assert_equal "Is there 1 translation to do?",   "Are there %d translations to do?".t(1)
    assert_equal "Are there 2 translations to do?", "Are there %d translations to do?".t(2)    
  end
  
  def test_pluralizable_string_with_non_whitespace_characters_after_pluralizable_word
    assert_equal "Omellette recipe (1 egg)",  "Omellette recipe (%d eggs)".t(1)
    assert_equal "Omellette recipe (2 eggs)", "Omellette recipe (%d eggs)".t(2)    
  end  
  
  def test_non_pluralizable_string_with_numeric_interpolation
    assert_equal "Omellette recipe (eggs: 1)",  "Omellette recipe (eggs: %d)".t(1)    
    assert_equal "Omellette recipe (eggs: 3)",  "Omellette recipe (eggs: %d)".t(3)    
  end
  
  def test_pluralizable_strings_with_adjectives_before_noun_dont_singularize
    assert_equal("Thomas has 1 old toys", "Thomas has %d old toys".t(1))
    assert_equal("Thomas has 10 old toys", "Thomas has %d old toys".t(10))
    
    assert_equal("Thomas has 1 old scrabby toys", "Thomas has %d old scrabby toys".t(1))
    assert_equal("Thomas has 10 old scrabby toys", "Thomas has %d old scrabby toys".t(10))    
  end
  
  
  def test_ignores_namespaces
    assert_equal "any old string", "any old string".t(:namespace)
    assert_equal "any old string", "any old %s".t(:namespace, 'string')
    assert_equal "any 1 string", "any %d strings".t(:namespace, 1)
    assert_equal "any 10 strings", "any %d strings".t(:namespace, 10)
    assert_equal "Tommy has 1 string", "%s has %d strings".t(:namespace, 1, 'Tommy')
    assert_equal "Tommy has 10 strings", "%s has %d strings".t(:namespace, 10, 'Tommy')
  end

end
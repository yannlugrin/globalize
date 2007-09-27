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

end
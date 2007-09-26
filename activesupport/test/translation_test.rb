require 'rubygems'
gem 'ruby-debug'
require 'ruby-debug'
Debugger.start

require File.dirname(__FILE__) + '/abstract_unit'

class TranslationTest < Test::Unit::TestCase
  def setup
    @string = "A string to be translated"
    @simple_interpolated_string = "%s must be translated"
    @plural_string = "%d translations"
    @interpolated_plural_string = "%s translated %d translations"    
    @multi_interpolated_plural_string = "%s & %s translated %d translations"    
  end

  def test_string
    assert_equal @string,   @string.t
    assert_equal 'This must be translated', @simple_interpolated_string.t('This')
    assert_equal '1 translation', @plural_string.t(1)
    assert_equal '2 translations', @plural_string.t(2)
    assert_equal "Tommy translated 1 translation",  @interpolated_plural_string.t('Tommy',1)
    assert_equal "Tommy translated 2 translations",  @interpolated_plural_string.t('Tommy',2)
    assert_equal "Tommy translated 1 translations",  @interpolated_plural_string.t('Tommy','1')    
    assert_equal "Tommy & Joe translated 2 translations",  @multi_interpolated_plural_string.t('Tommy','Joe',1)
    assert_equal "Tommy & Joe translated 2 translations",  @multi_interpolated_plural_string.t('Tommy','Joe',2)
  end
  
  def test_time
    assert_equal @string,   @string.t
  end  

end
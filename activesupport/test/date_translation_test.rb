#require 'rubygems'
#gem 'ruby-debug'
#require 'ruby-debug'
#Debugger.start

require File.dirname(__FILE__) + '/abstract_unit'

class DateTranslationTest < Test::Unit::TestCase

  def test_simple_date
    assert_equal "Thu Jan 01 1970", Date.new(1970,1,1).t.strftime('%a %b %d %Y')
  end
  
  def test_custom_translatable_time_class
    Object.class_eval <<-ENDDEF
      class ::ActiveSupport::Translation::TranslatableDate
        def overidden_strftime(*args)
          'overidden'
        end
        alias_method :old_strftime, :strftime        
        alias_method :strftime, :overidden_strftime
      end      
    ENDDEF
    
    assert_equal "overidden", Date.new(1970,1,1).t.strftime('%a %b %d %Y')
    
    Object.class_eval <<-ENDDEF
      class ::ActiveSupport::Translation::TranslatableDate
        alias_method :strftime, :old_strftime
      end      
    ENDDEF
    
    assert_equal "Thu Jan 01 1970", Date.new(1970,1,1).t.strftime('%a %b %d %Y')
  end
end
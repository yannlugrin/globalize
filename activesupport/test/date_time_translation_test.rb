#require 'rubygems'
#gem 'ruby-debug'
#require 'ruby-debug'
#Debugger.start

require File.dirname(__FILE__) + '/abstract_unit'

class DateTimeTranslationTest < Test::Unit::TestCase

  def test_simple_date_time
    assert_equal "Thu Jan 01 01:00:00 1970", DateTime.new(1970,1,1,1,0,0).t.strftime('%a %b %d %H:%M:%S %Y')
  end
  
  def test_custom_translatable_time_class
    Object.class_eval <<-ENDDEF
      class ::ActiveSupport::Translation::TranslatableDateTime
        def overidden_strftime(*args)
          'overidden'
        end
        alias_method :old_strftime, :strftime        
        alias_method :strftime, :overidden_strftime
      end      
    ENDDEF
    
    assert_equal "overidden", DateTime.new(1970,1,1,1,0,0).t.strftime('%a %b %d %H:%M:%S %Y')
    
    Object.class_eval <<-ENDDEF
      class ::ActiveSupport::Translation::TranslatableDateTime
        alias_method :strftime, :old_strftime
      end      
    ENDDEF
    
    assert_equal "Thu Jan 01 01:00:00 1970", DateTime.new(1970,1,1,1,0,0).t.strftime('%a %b %d %H:%M:%S %Y')
  end
end
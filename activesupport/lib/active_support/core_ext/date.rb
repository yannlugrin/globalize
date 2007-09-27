require 'date'
require File.dirname(__FILE__) + '/date/behavior'
require File.dirname(__FILE__) + '/date/calculations'
require File.dirname(__FILE__) + '/date/conversions'
require File.dirname(__FILE__) + '/date/translation'

class Date#:nodoc:
  include ActiveSupport::CoreExtensions::Date::Behavior
  include ActiveSupport::CoreExtensions::Date::Calculations
  include ActiveSupport::CoreExtensions::Date::Conversions
  include ActiveSupport::CoreExtensions::Date::Translation
end

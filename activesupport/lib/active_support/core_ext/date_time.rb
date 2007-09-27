require 'date'
require "#{File.dirname(__FILE__)}/time/behavior"
require "#{File.dirname(__FILE__)}/date_time/calculations"
require "#{File.dirname(__FILE__)}/date_time/conversions"
require "#{File.dirname(__FILE__)}/date_time/translation"

class DateTime
  include ActiveSupport::CoreExtensions::Time::Behavior
  include ActiveSupport::CoreExtensions::DateTime::Calculations
  include ActiveSupport::CoreExtensions::DateTime::Conversions
  include ActiveSupport::CoreExtensions::DateTime::Translation
end

require 'date'
require 'time'

# Ruby 1.8-cvs and 1.9 define private Time#to_date
class Time
  %w(to_date to_datetime).each do |method|
    public method if private_instance_methods.include?(method)
  end
end

require File.dirname(__FILE__) + '/time/behavior'
require File.dirname(__FILE__) + '/time/calculations'
require File.dirname(__FILE__) + '/time/conversions'
require File.dirname(__FILE__) + '/time/translation'

class Time#:nodoc:
  include ActiveSupport::CoreExtensions::Time::Behavior
  include ActiveSupport::CoreExtensions::Time::Calculations
  include ActiveSupport::CoreExtensions::Time::Conversions
  include ActiveSupport::CoreExtensions::Time::Translation
end

module ActiveRecord::Validations::ClassMethods
  def validates_length_of(*attrs)
    # Merge given options with defaults.
    options = {:too_long     => ActiveRecord::Errors.default_error_messages[:too_long],
               :too_short    => ActiveRecord::Errors.default_error_messages[:too_short],
               :wrong_length => ActiveRecord::Errors.default_error_messages[:wrong_length]}.merge(DEFAULT_VALIDATION_OPTIONS)
    options.update(attrs.pop.symbolize_keys) if attrs.last.is_a?(Hash)

    # Ensure that one and only one range option is specified.
    range_options = ALL_RANGE_OPTIONS & options.keys
    case range_options.size
      when 0
        raise ArgumentError, 'Range unspecified.  Specify the :within, :maximum, :minimum, or :is option.'
      when 1
        # Valid number of options; do nothing.
      else
        raise ArgumentError, 'Too many range options specified.  Choose only one.'
    end

    # Get range option and value.
    option = range_options.first
    option_value = options[range_options.first]

    # Declare different validations per option.
    validity_checks = { :is => "==", :minimum => ">=", :maximum => "<=" }
    message_options = { :is => :wrong_length, :minimum => :too_short, :maximum => :too_long }

    case option
    when :within, :in
      raise ArgumentError, ':within must be a Range' unless option_value.is_a?(Range) # '
      (options_without_range = options.dup).delete(option)
      (options_with_minimum = options_without_range.dup).store(:minimum, option_value.begin)
      validates_length_of attrs, options_with_minimum
      (options_with_maximum = options_without_range.dup).store(:maximum, option_value.end)
      validates_length_of attrs, options_with_maximum
    when :is, :minimum, :maximum
      raise ArgumentError, ":#{option} must be a nonnegative Integer" unless option_value.is_a?(Integer) and option_value >= 0 # '
      message = options[:message] || options[message_options[option]]
      message = [message, option_value] rescue message
      validates_each(attrs, options) do |record, attr, value|
        record.errors.add(attr, message) if value.nil? or !value.size.method(validity_checks[option])[option_value]
      end
    end
  end
end

# Make validation messages translatable
class ActiveRecord::Errors
  def each
    @errors.each_key { |attr| @errors[attr].each { |msg| yield attr.t, (msg.is_a?(Array) ? (msg[0] % [msg[1]]) : msg) } }
  end
  def full_messages
    full_messages = []
    @errors.each_key do |attr|
      @errors[attr].each do |msg|
        next if msg.nil?
        if attr == "base"
          full_messages << (msg.is_a?(Array) ? (msg[0].t % [msg[1]]) : msg)
        elsif msg.is_a?(Array)
          full_messages << (@base.class.human_attribute_name(attr) + " " + msg[0]).t % [msg[1]]
        else
          full_messages << (@base.class.human_attribute_name(attr) + " " + msg).t
        end
      end
    end
    full_messages
  end
end

require 'multilingual/rails/lib/db_translate'
class ActiveRecord::Base
  include Multilingual::DbTranslate
end

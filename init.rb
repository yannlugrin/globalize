require 'jcode'
$KCODE = 'u' # Always use UTF-8 internally!

require 'pathname'

root_path = directory   # this is set in the initializer that calls init.rb
ml_lib_path = "#{root_path}/lib/multilingual"

# Load all multilingual libs
Dir.glob("#{ml_lib_path}/localization/*.rb") { |file| require file }

# Load plugin models
require "multilingual/models/translation"
require "multilingual/models/model_translation"
require "multilingual/models/view_translation"
require "multilingual/models/language"
require "multilingual/models/country"
require "multilingual/models/currency"

# Load all Rails modules
Dir.glob("#{ml_lib_path}/rails/*.rb") { |file| require file }

# Hook up core extenstions (need to define them as main level, hence 
# the :: prefix)
class ::String  # :nodoc:
  include Multilingual::CoreExtensions::String
end

class ::Symbol  # :nodoc:
  include Multilingual::CoreExtensions::Symbol
end

class ::Object  # :nodoc:
  include Multilingual::CoreExtensions::Object
end

class ::Fixnum  # :nodoc:
  alias_method :multilingual_old_to_s, :to_s
  include Multilingual::CoreExtensions::Fixnum
  alias_method :to_s, :multilingual_new_to_s
end

class ::Bignum  # :nodoc:
  alias_method :multilingual_old_to_s, :to_s
  include Multilingual::CoreExtensions::Bignum
  alias_method :to_s, :multilingual_new_to_s
end

class ::Float  # :nodoc:
  alias_method :multilingual_old_to_s, :to_s
  include Multilingual::CoreExtensions::Float
  alias_method :to_s, :multilingual_new_to_s
end

class ::Time  # :nodoc:
  alias_method :multilingual_old_strftime, :strftime
  include Multilingual::CoreExtensions::Time
  alias_method :strftime, :multilingual_new_strftime
end

class ::Date # :nodoc:
  alias_method :multilingual_old_strftime, :strftime
  include Multilingual::CoreExtensions::Date
  alias_method :strftime, :multilingual_new_strftime
end

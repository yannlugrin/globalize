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

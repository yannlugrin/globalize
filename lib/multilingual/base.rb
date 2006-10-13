MLR_ROOT = File.expand_path(File.dirname(__FILE__))

begin
  require 'unicode'
rescue LoadError
  RAILS_DEFAULT_LOGGER.error "You don't have ruby-unicode installed! Unicode case-manipulaton and normalization disabled."
end

begin
  require 'iconv'
  require 'kconv'
rescue LoadError
  RAILS_DEFAULT_LOGGER.error "You don't have ruby-iconv installed! Charset conversion not available."
end

require 'jcode'
$KCODE = 'u' # Always use UTF-8 internally!

require_dependency "#{MLR_ROOT}/locale"
require_dependency "#{MLR_ROOT}/translators/abstract"

# Load all Rails modules
Dir.glob("#{MLR_ROOT}/rails/*.rb") { |file| require_dependency file }

# Load plugin models
Dir.glob("#{MLR_ROOT}/models/*.rb") { |file| require_dependency file }

# These are static (unless when developing the Multilingual Rails framework
# itself) so require them normally.
require "#{MLR_ROOT}/core_ext"
require "#{MLR_ROOT}/iso"

# Set translator
require_dependency "#{MLR_ROOT}/translators/default"
DEFAULT_MLR_TRANSLATOR = Locale::DefaultTranslator

# Locale path, relative to SITE_ROOT or RAILS_ROOT
DEFAULT_MLR_LOCALE_PATH = '/config/locale'

# Path to log-file(s). %s is the current locale.
if Object.const_defined? :SITE_ROOT
  DEFAULT_MLR_LOG_PATH = "#{SITE_ROOT}/log/translation-misses/%s.log"
else
  DEFAULT_MLR_LOG_PATH = "#{RAILS_ROOT}/log/translation-misses/%s.log"
end  

# Log format. %1$s is the translation mode (application/content),
# %2$s is the current locale, %3$s is the missed string,
# %4$s is the current time.
DEFAULT_MLR_LOG_FORMAT = "%4$s: [%1$s] |%3$s|"
  
# ISO 3166 code to use. Can be :numeric, :alpha2 or :alpha3. Default is :numeric
DEFAULT_MLR_ISO3166_CODE = 'numeric'

# Set default locale
Locale.set(ENV['LC_ALL'] || ENV['LANG'] || 'en_US')

# Set base language for content (language with complete coverage)
Locale.set_base(ENV['LC_ALL'] || ENV['LANG'] || 'en_US')

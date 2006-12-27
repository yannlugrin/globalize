require 'ruby-debug'
Debugger.start

ENV["RAILS_ENV"] = "test"

rails_environment_path = File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')
plugin_path = ""

if File.exist? rails_environment_path
  require rails_environment_path
  plugin_path = RAILS_ROOT + "/vendor/plugins/globalize"
else
  require 'active_record'
  require 'active_record/fixtures'
  require 'action_pack'
  require 'action_mailer'
  directory = File.expand_path(File.dirname(__FILE__) + '/../')
  plugin_path = directory
  init_path = File.expand_path(File.dirname(__FILE__) + '/../init.rb')
  silence_warnings { eval(IO.read(init_path), binding, init_path) }
end

require 'logger'
require 'test_help'

config_location = plugin_path + "/test/config/database.yml"

config = YAML::load(ERB.new(IO.read(config_location)).result)
ActiveRecord::Base.logger = Logger.new(plugin_path + "/test/log/test.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'mysql'])

schema_file = plugin_path + "/test/db/schema.rb"
load(schema_file) if File.exist?(schema_file)

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)
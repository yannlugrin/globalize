ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')
require 'logger'
require 'test_help'
require 'stringio'

plugin_path = RAILS_ROOT + "/vendor/plugins/globalize"

config_location = plugin_path + "/test/config/database.yml"

config = YAML::load(ERB.new(IO.read(config_location)).result)
ActiveRecord::Base.logger = Logger.new(plugin_path + "/test/log/test.log")
ActiveRecord::Base.establish_connection(config['test'])

schema_file = plugin_path + "/test/db/schema.rb"
load(schema_file) if File.exist?(schema_file)

Test::Unit::TestCase.fixture_path = plugin_path + "/test/fixtures/"

$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)


def assert_stderr_equal(string, msg = nil, &block)
  assert_stderr do |std_err_output|
    block.call
    assert_equal string, std_err_output, msg
  end
end

def assert_stderr_empty(msg = nil, &block)
  assert_stderr do |std_err_output|
    block.call
    assert_equal '', std_err_output, msg
  end
end

def assert_stderr(std_err_output = '', &block)
  begin
    old_std_err = $stderr
    $stderr = StringIO.new(std_err_output)
    block.call(std_err_output)
  ensure
    $stderr = old_std_err
  end
end

def assert_stdout(std_output = '', &block)
  begin
    old_std_out = $stdout
    $stdout = StringIO.new(std_output)
    block.call(std_output)
  ensure
    $stdout = old_std_out
  end
end

def assert_includes(object, collection, msg= nil)
  assert(collection.include?(object), msg)
end
desc "Run the unit tests for the multilingual rails plugin"
Rake::TestTask.new "test_multilingual" do |t|
  t.pattern = "./vendor/plugins/multilingual/test/*_test.rb"
  t.verbose = true
end

Rake::RDocTask.new(:rdoc_multilingual) do |rd|
  plugin_dir = "./vendor/plugins/multilingual"
  rd.main = plugin_dir + "/README"
  rd.rdoc_files.include(plugin_dir + "/README",
    plugin_dir + "/lib/multilingual/rails/**/*.rb",
    plugin_dir + "/lib/multilingual/models/**/*.rb",
    plugin_dir + "/lib/multilingual/translators/**/*.rb",
    plugin_dir + "/lib/multilingual/*.rb"
  )
  rd.rdoc_dir = plugin_dir + "/doc"
end
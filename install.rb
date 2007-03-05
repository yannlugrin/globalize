RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../')
puts RAILS_ROOT
`cd #{RAILS_ROOT};rake globalize:upgrade_schema_to_1_dot_2`
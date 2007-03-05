APP_ROOT = File.join(File.dirname(__FILE__), '../../../')
puts APP_ROOT
`cd #{APP_ROOT} && rake globalize:upgrade_schema_to_1_dot_2`
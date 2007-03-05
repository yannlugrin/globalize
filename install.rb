APP_ROOT = File.join(File.dirname(__FILE__), '../../../')
`echo rake -f #{APP_ROOT}Rakefile globalize:upgrade_schema_to_1_dot_2`
`rake -f #{APP_ROOT}Rakefile globalize:upgrade_schema_to_1_dot_2`
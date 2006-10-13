require 'zlib'
require 'pathname'

class MultilingualGenerator < MigrationGenerator
  def initialize(runtime_args, runtime_options = {})
    super([ "multilingual_migration" ] + runtime_args, runtime_options = {})
  end

  def banner
    "Usage: script/generate multilingual [options]"
  end

  def inflate_schema
    inflated_path = source_path('migration.rb')
    deflated_path = source_path('migration.rb.gz')
    return if File.exist?(inflated_path)
    return if !File.exist?(deflated_path)

    File.open(inflated_path, 'w') do |f|
      Zlib::GzipReader.open(deflated_path) do |gzip|
        gzip.each do |line|
          f.puts line
        end
      end
    end
  end

  def manifest
    record do |m|
      m.directory 'db/migrate'
      m.inflate_schema
      m.migration_template 'migration.rb', 'db/migrate'
    end
  end
end


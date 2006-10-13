# Search for translated templates or fall back to the default one
module ActionView
  class Base
    private
      def full_template_path(template_path, extension)
        @cached_paths ||= {}
        if @cached_paths.has_key? "#{template_path}:#{extension}:#{Locale.current}"
          return @cached_paths["#{template_path}:#{extension}:#{Locale.current}"]
        end

        paths = []
        basename = File.basename(template_path)
        dirname  = File.dirname(template_path)
        if Object.const_defined?('SITE_ROOT') # Productized application
          paths << "#{SITE_ROOT}/app/views/#{template_path}.#{Locale.current}.#{extension}"
          paths << "#{SITE_ROOT}/app/views/#{template_path}.#{Locale.current.split('_').first}.#{extension}"
          paths << "#{SITE_ROOT}/app/views/#{dirname}/#{Locale.current}/#{basename}.#{extension}"
          paths << "#{SITE_ROOT}/app/views/#{dirname}/#{Locale.current.split('_').first}/#{basename}.#{extension}"
          paths << "#{SITE_ROOT}/app/views/#{dirname}/#{Locale.current}.#{extension}"
          paths << "#{SITE_ROOT}/app/views/#{dirname}/#{Locale.current.split('_').first}.#{extension}"
          paths << "#{SITE_ROOT}/app/views/#{template_path}.#{extension}"
          paths << "#{SITE_ROOT}/app/views/#{dirname}/_default.#{extension}"
        end
        paths << "#{@base_path}/#{template_path}.#{Locale.current}.#{extension}"
        paths << "#{@base_path}/#{template_path}.#{Locale.current.split('_').first}.#{extension}"
        paths << "#{@base_path}/#{dirname}/#{Locale.current}/#{basename}.#{extension}"
        paths << "#{@base_path}/#{dirname}/#{Locale.current.split('_').first}/#{basename}.#{extension}"
        paths << "#{@base_path}/#{dirname}/#{Locale.current}.#{extension}"
        paths << "#{@base_path}/#{dirname}/#{Locale.current.split('_').first}.#{extension}"
        paths << "#{@base_path}/#{template_path}.#{extension}"
        paths << "#{@base_path}/#{dirname}/_default.#{extension}"

        paths.each do |p|
          if File.exists?(p)
            @cached_paths["#{template_path}:#{extension}:#{Locale.current}"] = p
            return p
          end
        end
        return "#{@base_path}/#{template_path}.#{extension}"
      end
  end
end

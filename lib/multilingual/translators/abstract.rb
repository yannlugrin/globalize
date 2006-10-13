class Locale::AbstractTranslator
  attr_reader :locales

  def initialize
    reload!
  end
  def reload!
    @defaults = {}
    @locales = {}
  end

  def translate(string,locale,count=0)
    self.reload! if RAILS_ENV == 'development'
    load_locale_data(locale) unless @locales.has_key? locale
    load_defaults(locale) unless @defaults.has_key? locale

    to_check(locale).each do |locale|
      @locales[locale] ||= {}
      return @locales[locale][string][0], @locales[locale][string][1..-1] if @locales[locale].has_key?(string)
    end
    return @defaults[locale][string][0], @defaults[locale][string][1..-1] if @defaults[locale].has_key?(string)
    
    @@log_path ||= false
    unless @@log_path
      if Locale.const_defined? :MLR_LOG_PATH
        @@log_path = MLR_LOG_PATH
      else
        @@log_path = DEFAULT_MLR_LOG_PATH
      end
    end
    
    @@log_format ||= false
    unless @@log_format
      if Locale.const_defined? :MLR_LOG_FORMAT
        @@log_format = MLR_LOG_FORMAT
      else
        @@log_format = DEFAULT_MLR_LOG_FORMAT
      end
    end

    FileUtils.mkdir_p File.dirname(@@log_path % [Locale.current])
    RAILS_DEFAULT_LOGGER.class.new(@@log_path % [Locale.current]).warn(
      @@log_format % ['application', Locale.current, string, Time.now.strftime('%Y-%m-%d %H:%M:%S')]
    )
    @locales[locale][string] = [string]
    return string
  end
  
  protected
    def to_check(locale)
      if locale =~ /(\w+)_(\w+)/
        return [$1,locale]
      else
        return [locale]
      end
    end

  private
    def load_defaults(locale)
      @defaults[locale] = {}
      to_check(locale).each do |f|
        if File.exists?( "#{MLR_ROOT}/locales/#{f}.rb" )
          eval File.read( "#{MLR_ROOT}/locales/#{f}.rb" )
          @defaults[locale].update @translation
          @translation = nil
        end
      end
      @defaults[locale]
    end

    def load_locale_data(locale)
      # This method must be overloaded to fill @locales with locale data.
      raise "load_files not implemented!"
    end
    
    def set_log_path
      @@log_path ||= false
      return if @@log_path
      if Locale.const_defined? :MLR_LOG_PATH
        @@log_path = MLR_LOG_PATH
      else
        @@log_path = DEFAULT_MLR_LOG_PATH
      end
    end
end

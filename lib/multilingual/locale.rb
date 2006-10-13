module Locale
  @@lang_data = {}
  @@country_data = {}
  
  def self.set_base(locale)
    @@base_locale = locale
    @@base_language = locale.split('_').first
    Language.base_language_code = @@base_language
  end
  def self.base_language; @@base_language; end
  
  def self.set(locale)
    @@current_locale  = locale
    @@current_language, @@current_country = locale.split('_')
    Language.active_language_code = @@current_language
    
    ['.utf8','.UTF-8','.utf-8','.UTF8',''].each do |encoding|
      begin
        setlocale(Locale::LC_ALL => "#{locale}#{encoding}")
        @@current_locale = "#{locale}#{encoding}"
        break
      rescue
        next
      end
    end
    
    load_lang_data(locale)
    load_country_data(@@current_country)

    Date::MONTHNAMES.replace @@lang_data[@@current_locale][:months]
    Date::DAYNAMES.replace @@lang_data[@@current_locale][:days]
    true
  end

  def self.current(full=false)
    return @@current_locale if full
    @@current_locale.split('.').first
  end

  def self.current_language(full=false)
    return @@current_language if full
    @@current_language.split('.').first
  end

  def self.reload!
    @@countries = {}
    @@languages = {}
    @@country_data = {}
    @@lang_data = {}

    load_translator
    @@translator.reload!
  end
  
  def self.translate(*args)
    load_translator
    @@translator.translate(*args)
  end
  
  def self.day(d)     ; @@lang_data[current][:days][d]     ; end
  def self.abday(d)   ; @@lang_data[current][:abdays][d]   ; end
  def self.month(m)   ; @@lang_data[current][:months][m]   ; end
  def self.abmonth(m) ; @@lang_data[current][:abmonths][m] ; end
  
  private
    def self.load_translator
      @@translator ||= false
      return if @@translator
      if Locale.const_defined? :MLR_TRANSLATOR
        @@translator = MLR_TRANSLATOR.new
      else
        @@translator = DEFAULT_MLR_TRANSLATOR.new
      end
    end
    
    def self.load_lang_data(locale)
      return @@lang_data[locale] if @@lang_data.has_key?(locale)
      to_check(locale).each do |f|
        if File.exists?( "#{MLR_ROOT}/locales/lang-data/#{f}.rb" )
          eval File.read( "#{MLR_ROOT}/locales/lang-data/#{f}.rb" )
          @@lang_data[locale] = @lang_data
          @lang_data = nil
        end
      end
      @@lang_data[locale]
    end
    def self.load_country_data(country)
      return @@country_data[country] if @@country_data.has_key?(country)
      if File.exists?( "#{MLR_ROOT}/locales/country-data/#{country}.rb" )
        eval File.read( "#{MLR_ROOT}/locales/country-data/#{country}.rb" )
        @@country_data[country] = @country_data
        @country_data = nil
      end
      @@country_data[country]
    end
    
end

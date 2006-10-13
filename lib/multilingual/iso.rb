module Locale
  @@countries = {}
  @@languages = {}
  
  # Generate ISO conversion functions
  Dir.glob("#{MLR_ROOT}/tables/*.rb") do |f|
    table = File.basename(f,'.rb')
    if table =~ /num_to_/
      module_eval <<-EOE
        def self.#{table}(var)
          get_from_table :#{table}, var.to_i
        end
      EOE
    else
      module_eval <<-EOE
        def self.#{table}(var)
          get_from_table :#{table}, var.to_s.upcase
        end
      EOE
    end
  end


  def self.country(code, variant=:formal, locale=nil)
    code = ( (MLR_ISO3166_CODE || DEFAULT_MLR_ISO3166_CODE).to_s == 'numeric' ? code.to_i : code.to_s )
    country = countries(locale || current)[code]
    country.nil? ? nil : country[variant]
  end

  def self.language(iso639_1, locale=nil)
    languages(locale || current)[iso639_1.to_s.upcase]
  end

  def self.countries(locale=nil)
    locale ||= current
    locale = locale.to_s
    unless @@countries.has_key?(locale)
      @@countries[locale] = {}
      to_check(locale).each do |lc|
        if File.exists? File.dirname(__FILE__) + "/locales/iso3166/#{lc}_#{(MLR_ISO3166_CODE || DEFAULT_MLR_ISO3166_CODE).to_s}.rb"
          eval File.read( File.dirname(__FILE__) + "/locales/iso3166/#{lc}_#{(MLR_ISO3166_CODE || DEFAULT_MLR_ISO3166_CODE).to_s}.rb" )
          @@countries[locale].update(@countries)
        end
      end
      @countries = nil
    end
    @@countries[locale]
  end

  def self.languages(locale=nil)
    locale ||= current
    locale = locale.to_s
    unless @@languages.has_key?(locale)
      @@languages[locale] = {}
      to_check(locale).each do |lc|
        if File.exists? File.dirname(__FILE__) + "/locales/iso639-1/#{lc}.rb"
          eval File.read( File.dirname(__FILE__) + "/locales/iso639-1/#{lc}.rb" )
          @@languages[locale].update(@languages)
        end
      end
      @languages = nil
    end
    @@languages[locale]
  end



  private
    def self.get_from_table(table, var)
      @@tables ||= {}
      unless @@tables.has_key? table
        eval File.read("#{MLR_ROOT}/tables/#{table.to_s}.rb")
      end
      @@tables[table][var]
    end
  
    def self.to_check(locale)
      return ['en'] if locale[0..2] == 'en'
      if locale =~ /(\w+)_(\w+)/
        ['en',$1,locale]
      else
        ['en',locale]
      end
    end
end

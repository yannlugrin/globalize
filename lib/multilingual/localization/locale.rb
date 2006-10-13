module Multilingual
  class Locale

    attr_reader :language, :country, :code
    attr_accessor :date_format, :currency_format, :currency_code,
      :measurement_system, :thousands_sep, :decimal_sep

    @@cache = {}
    @@translator_class = DbViewTranslator
    @@translator = {}
    @@active = nil

    def self.active?; !@@active.nil? end

    def self.set(locale)
      if locale.kind_of? Locale
        @@active = locale
      else
        @@active = ( @@cache[locale] ||= Locale.new(locale) )
      end
    end
    def self.active; @@active end

    def self.base_language; @@base_language end
    def self.set_base_language(lang)
      if lang.kind_of? Language
        @@base_language = lang
      else
        @@base_language = Language.pick(lang)
      end
    end

    def self.base?
      active.language == base_language
    end

    def initialize(code)
      rfc = RFC_3066.parse(code)
      @code = rfc.locale

      @language = Language.pick(rfc)
      @country = Country.pick(rfc) 

      setup_fields
    end

    def self.translator
      language = active.language
      @@translator[language] ||= @@translator_class.new(language)
    end

    private
      def setup_fields
        return if !@country

        [:date_format, :currency_format, :currency_code, :measurement_system, :thousands_sep, 
          :decimal_sep].each {|f| instance_variable_set "@#{f}", @country.send(f) }
      end
  end
end


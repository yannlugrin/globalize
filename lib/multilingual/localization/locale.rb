module Multilingual

=begin rdoc
  Locale defines the currenctly active _locale_. You'll mostly use it like this:
    Locale.set("en-US")

  +en+ is the code for English, and +US+ is the country code. The country code is 
  optional, but you'll need to define it to get a lot of the localization features.
=end  
  class Locale

    attr_reader :language, :country, :code
    attr_accessor :date_format, :currency_format, :currency_code,
      :thousands_sep, :decimal_sep, :currency_decimal_sep,
      :number_grouping_scheme

    @@cache = {}
    @@translator_class = DbViewTranslator
    @@translator = {}
    @@active = nil
    @@base_language = nil

    # Is there an active locale?
    def self.active?; !@@active.nil? end

    # This is the main point of the class. Sets the locale in the familiar
    # RFC 3066 format (see: http://www.faqs.org/rfcs/rfc3066.html). It also
    # takes Locale objects, and the +nil+ object, to deactivate the locale.
    def self.set(locale)
      if locale.kind_of? Locale
        @@active = locale
      elsif locale.nil?
        @@active = nil
      else
        @@active = ( @@cache[locale] ||= Locale.new(locale) )
      end
    end

    # Returns the active locale.
    def self.active; @@active end

    # Sets the base language. The base language is the language that has
    # complete coverage in the database. For instance, if you have a +Category+
    # model with a +name+ field, the base language is the language in which names
    # are stored in the model itself, and not in the translations table.
    #
    # Takes either a language code (2 or 3 letters) or a language object.
    def self.set_base_language(lang)
      if lang.kind_of? Language
        @@base_language = lang
      else
        @@base_language = Language.pick(lang)
      end
    end

    # Returns the base language.
    def self.base_language; @@base_language end

    # Is the currently active language the base language?
    def self.base?
      active ? active.language == base_language : true
    end

    # Creates a new locale object by looking up a RFC 3066 code in the database.
    def initialize(code)
      if code.nil?
        return
      end

      rfc = RFC_3066.parse(code)
      @code = rfc.locale

      @language = Language.pick(rfc)
      @country = Country.pick(rfc) 

      setup_fields
    end


    def self.translate(key, num = nil, default = nil) # :nodoc"
      key = key.to_s.gsub('_', ' ') if key.kind_of? Symbol

      # allows shortcut default calling
      if default.nil? && num.kind_of?(String)
        default = num
        num = nil
      end
      default ||= key
      translator = self.translator
      translator ? translator.fetch(key, num, default) : default
    end

    private
      def self.translator
        return nil if !active || !active.language
        language = active.language
        @@translator[language] ||= @@translator_class.new(language)
      end

      def setup_fields
        return if !@country

        [:date_format, :currency_format, :currency_code, :thousands_sep, 
          :decimal_sep, :currency_decimal_sep, :number_grouping_scheme
        ].each {|f| instance_variable_set "@#{f}", @country.send(f) }
      end
  end
end


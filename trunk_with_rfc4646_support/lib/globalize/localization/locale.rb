require 'stringio'
module Globalize

  class NoBaseLanguageError < StandardError; end

=begin rdoc
  Locale defines the currenctly active _locale_. You'll mostly use it like this:
    Locale.set("en-US")

  +en+ is the code for English, and +US+ is the country code. The country code is
  optional, but you'll need to define it to get a lot of the localization features.
=end
  class Locale
    attr_reader :language, :country, :code, :rfc
    attr_accessor :date_format, :currency_format, :currency_code,
      :thousands_sep, :decimal_sep, :currency_decimal_sep,
      :number_grouping_scheme

    @@cache = {}
    @@translator_class = DbViewTranslator
    @@active = nil
    @@base_language = nil
    @@base_language_code = nil
    @@translator = @@translator_class.instance

=begin
 Creates a new locale object by looking up an RFC 3066 code in the database.
=end
    def initialize(language_tag, country_code = nil, fallbacks = nil)
      return nil unless language_tag

      unless country_code.blank?
        @rfc = RFC_4646.parse(language_tag)
        @code = @rfc.tag
        @country = Country.pick(country_code)
      else
        @rfc = RFC_3066.parse(language_tag)
        @code = @rfc.locale
        @country = Country.pick(@rfc)
        $stderr.puts "Locale.new(locale) is deprecated! Use Locale.new(language_tag, country_code)." unless caller.any? {|stack_entry| stack_entry =~ /`set'/}
      end

      @language = Language.pick(@rfc)

      setup_fields
      setup_fallbacks(fallbacks)
    end

    def eql?(object)
      self == (object)
    end

    def ==(object)
      object.equal?(self) ||
        (object.instance_of?(self.class) &&
          object.language == language && object.country == country)
    end

    def valid?
      @language && @country && @rfc
    end

    def fallbacks
      if @language_fallbacks && @rfc.kind_of?(RFC_3066)
        $stderr.puts "Fallbacks can only be defined using the Locale.set(language_tag, country_code) syntax."
        nil
      else
        @language_fallbacks
      end
    end

    # Is there an active locale?
    def self.active?; !@@active.nil? end

    # This is the focal point of the class. Sets the locale in the familiar
    # RFC 3066 format (see: http://www.faqs.org/rfcs/rfc3066.html). It can
    # also take a Locale object. Set it to the +nil+ object, to deactivate
    # the locale.
    def self.set(locale_or_language_tag, country_code = nil, fallbacks = nil)
      if locale_or_language_tag.kind_of? Locale
        @@active = locale_or_language_tag
      elsif locale_or_language_tag.nil?
        @@active = nil
      else
        locale_or_language_tag = locale_or_language_tag.code if locale_or_language_tag.kind_of? Language
        case country_code
          when nil, ''
            $stderr.puts "Locale.set(locale) is deprecated! Use Locale.set(language_tag, country_code)."
            $stdout.puts caller.inspect unless $stderr.kind_of?(StringIO)
            locale_tag = locale_or_language_tag
            @@active = ( @@cache[locale_tag] ||= Locale.new(locale_or_language_tag, nil, fallbacks) )
          when Country
            locale_tag = "#{locale_or_language_tag}_#{country_code.code}"
            @@active = ( @@cache[locale_tag] ||= Locale.new(locale_or_language_tag, country_code.code, fallbacks) )
          else
            locale_tag = "#{locale_or_language_tag}_#{country_code}"
            @@active = ( @@cache[locale_tag] ||= Locale.new(locale_or_language_tag, country_code, fallbacks) )
        end
      end
    end

    # Clears the locale cache -- used mostly for testing.
    def self.clear_cache
      @@cache.clear
    end

    # Returns the active locale.
    def self.active; @@active end

    # Sets the base language. The base language is the language that has
    # complete coverage in the database. For instance, if you have a +Category+
    # model with a +name+ field, the base language is the language in which names
    # are stored in the model itself, and not in the translations table.
    #
    # Takes either a language code (valid RFC 3066 code like +en+ or <tt>en-US</tt>)
    # or a language object.
    #
    # May be set with a language code in environment.rb, without accessing the db.
    #Note: The language tag is now parsed as an rfc_4646 tag.
    #i.e. If you just mean english, use 'en'.
    #Don't use 'en-US' (with country code) unless you want the
    #North Americant reginal variant of English.
    def self.set_base_language(language_tag)
      if language_tag.kind_of? Language
        @@base_language = language_tag
      else
        @@base_language_code = RFC_4646.parse language_tag
      end
    end

    # Returns the base language. Raises an exception if none is set.
    def self.base_language
      @@base_language ? @@base_language :
        (@@base_language_code ?
        (@@base_language = Language.pick(@@base_language_code)) :
        raise(NoBaseLanguageError, "base language must be defined"))
    end

    # Is the currently active language the base language?
    def self.base?
      active ? active.language == base_language : true
    end

    # Returns the currently active language model or +nil+.
    def self.language
      active? ? active.language : nil
    end

    # Returns the currently active language code or +nil+.
    def self.language_code
      active? ? language.code : nil
    end

    # Returns the currently active country model or +nil+.
    def self.country
      active? ? active.country : nil
    end

    # Allows you to switch the current locale while within the block.
    # The previously current locale is restored after the block is finished.
    #
    # e.g
    #     Locale.set('en','US')
    #     Locale.switch_locale('es','ES') do
    #       product.name = 'esquis'
    #     end
    #
    #     product.name
    #     > skis
    def self.switch_locale(language_tag, country_code = nil, fallbacks = nil, &block)
      current_locale = Locale.active
      raise ArgumentError, 'at least one argument is required' if language_tag.blank? && country_code.blank?

      language_tag = current_locale.language if language_tag.blank?

      Locale.set(language_tag, country_code, fallbacks)
      result = block.call
      Locale.set(current_locale)
      result
    end


    # Allows you to switch the current locale's language while within the block.
    # The current locale's country is maintained
    # The previously current language is restored after the block is finished.
    #
    # e.g
    #     Locale.set('es','ES')
    #     Locale.switch_locale('ca') do
    #       product.name = 'mitjons'
    #       Locale.country => Spain
    #     end
    #
    #     product.name
    #     > calcetines
    #       Locale.country => Spain
    def self.switch_language(language_tag, fallbacks = nil, &block)
      current_locale = Locale.active
      Locale.set(language_tag, current_locale.country, fallbacks)
      result = block.call
      Locale.set(current_locale)
      result
    end

    # Allows you to switch the current locale's country while within the block.
    # The current locale's language is maintained
    # The previously current country is restored after the block is finished.
    #
    # e.g
    #     Locale.set('en','US')
    #     Locale.switch_locale('CA') do
    #       Locale.country => Canada
    #     end
    #
    #     Locale.country => United States of America
    def self.switch_country(country_code, fallbacks = nil, &block)
      current_locale = Locale.active
      raise ArgumentError, "country_code is required" if country_code.blank?
      Locale.set(current_locale.language, country_code, fallbacks ? fallbacks : current_locale.fallbacks)
      result = block.call
      Locale.set(current_locale)
      result
    end

    # Sets the translation for +key+.
    #
    # :call-seq:
    #   Locale.set_translation(key, language, *translations)
    #   Locale.set_translation(key, *translations)
    #
    # If +language+ is given, define a translation using that language
    # model, otherwise use the active language.
    #
    # Multiple translation strings may be given, in order to define plural forms.
    # In English, there are only two plural forms, singular and plural, so you
    # would provide two strings at the most. The order is determined by the
    # formula in the languages database. For English, the order is: singular form,
    # then plural.
    #
    # Example:
    #   Locale.set_translation("There are %d items in your cart",
    #   "There is one item in your cart", "There are %d items in your cart")
    def self.set_translation(key, *options)
      key, language, translations, zero_form = key_and_language(key, options)
      raise ArgumentError, "No translations given" if options.empty?
      translator.set(key, language, translations, zero_form, nil)
    end

    # Same as set_translation but translation is set to a particular namespace
    #
    # Example:
    #   Locale.set('es-ES')
    #   Locale.set_translation("draw", "dibujar")
    #   "draw".t => "dibujar"
    #   Locale.set_translation_with_namespace("draw", "lottery", "seleccionar")
    #   "draw" >> 'lottery' => "seleccionar"
    #
    # or
    #   Locale.set_translation("draw %d times", "dibujar una vez", "dibujar %d veces")
    #   Locale.set_translation_with_namespace("draw %d times", "lottery", "seleccionar una vez", "seleccionar %d veces")
    def self.set_translation_with_namespace(key, namespace, *options)
      key, language, translations, zero_form = key_and_language(key, options)
      raise ArgumentError, "No translations given" if options.empty?
      translator.set(key, language, translations, zero_form, namespace)
    end

    def self.set_pluralized_translation(key, *options)
      key, language, translations, zero_form = key_and_language(key, options)
      raise ArgumentError, "No translations given" if options.empty?
      translator.set_pluralized(key, language, translations, zero_form, nil)
    end

    def self.set_pluralized_translation_with_namespace(key, *options)
      key, language, translations, zero_form = key_and_language(key, options)
      raise ArgumentError, "No translations given" if options.empty?
      translator.set_pluralized(key, language, translations, zero_form, namespace)
    end

    def self.translate(key, default = nil, arg = nil, namespace = nil) # :nodoc:
      key = key.to_s.gsub('_', ' ') if key.kind_of? Symbol

      translator.fetch(key, self.language, default, arg, namespace)
    end

    # Returns the translator object -- mostly for testing and adjusting the cache.
    def self.translator; @@translator end

    private

      def self.key_and_language(key, options)
        key = key.to_s.gsub('_', ' ') if key.kind_of? Symbol
        if options.first.kind_of? Language
          language = options.shift
        else
          language = self.language
        end

        zero_form = (options.first.kind_of?(Array) && options.last.kind_of?(String)) ? options.pop : nil
        [key,language,options.flatten, zero_form]
      end

      def setup_fields
        return if !@country

        [:date_format, :currency_format, :currency_code, :thousands_sep,
          :decimal_sep, :currency_decimal_sep, :number_grouping_scheme
        ].each {|f| instance_variable_set "@#{f}", @country.send(f) }
      end

      def setup_fallbacks(list_of_fallbacks)
        return unless list_of_fallbacks && list_of_fallbacks.kind_of?(Array)
        begin
          if list_of_fallbacks.all? {|flbck| flbck.kind_of? Locale }
            @language_fallbacks = list_of_fallbacks
          else
            @language_fallbacks = list_of_fallbacks.collect do |flbck|
              locale_tag = flbck[1].blank? ? flbck.first : "#{flbck[0]}_#{flbck[1]}"
              @@cache[locale_tag] ||= Locale.new(*flbck)
            end
          end
        rescue ArgumentError => ae
          raise ArgumentError, "ArgumentError for fallback! Nested Exception: #{ae.message}"
        end
      end
  end
end
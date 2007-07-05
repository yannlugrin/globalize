module Globalize #:nodoc:
  class SupportedLocales

    attr_accessor :supported_locales, :active_locales
    attr_accessor :base_locale, :default_locale
    attr_accessor :supported_locales_map, :active_locales_map
    attr_accessor :base_locale_object, :default_locale_object

=begin
    Class that encapsulates the concept of an applications supported locales.
    Allows specification of:

      * Supported locales

          e.g. SupportedLocales.define(['es-ES,'he-IL'])

        An application can support a number of locales
        (e.g. visible in both the front and back ends)

      * Globalize base locale

          e.g. SupportedLocales.define(['es-ES,'he-IL'], 'en-US')

        Note: This defaults to 'en-US' if unspecified

      * Active locales

          e.g. SupportedLocales.define(['es-ES,'he-IL','fr-FR'], 'en-US', ['es-ES,'fr-FR'])

        Perhaps you only want to allow certain locales to be visible in the front
        end while content in other locales is still being translated.

      * Default locale

        e.g. SupportedLocales.define(['es-ES,'he-IL','fr-FR'], 'en-US', ['es-ES,'fr-FR'], 'es-ES')

        Perhaps the default locale of your front end is distinct from the base
        locale used in the back end.

        Note: This defaults to the base locale if unspecified
=end
    def self.define(supported_locales = [], base_locale = 'en_US', active_locales = [], default_locale = nil)
      return @@instance if (defined?(@@instance) && @@instance)
      @@instance = new(supported_locales, base_locale, active_locales, default_locale)
    end

    def self.define_by_key(key, supported_locales = [], base_locale = 'en_US', active_locales = [], default_locale = nil)
      return @@instances[key] if (defined?(@@instances) && @@instances[key])
      @@instances ||= {}
      @@instances[key] = new(supported_locales, base_locale, active_locales, default_locale)
    end

    private_class_method  :new

    def self.instance
      if defined? @@instance
        @@instance.send(:setup) unless @@instance.supported_locales_map
        return @@instance
      end
    end

    def self.instances(key)
      if defined? @@instances
        @@instances[key].send(:setup) unless @@instances[key] && @@instances[key].supported_locales_map
        return @@instances[key]
      end
    end

    def self.clear(key = nil)
      @@instance = nil
      @@instances[key] = nil if key
    end

    def self.clear_all(key)
      @@instances = {}
    end

    def initialize(supported_locales, base_locale, active_locales, default_locale)
      @supported_locales = supported_locales
      @base_locale = base_locale

      @default_locale = default_locale
      @default_locale = base_locale.dup unless default_locale

      @active_locales = supported_locales.dup unless supported_locales.empty?
      @active_locales = active_locales unless active_locales.empty?

      raise "No supported Globalize locales defined. Please specify at least one!" if @supported_locales.empty?
    end

    class << self
      def supported_locale_codes(key = nil)
        return self.instance.supported_locales unless key
        return self.instances(key).supported_locales
      end

      def supported_locales(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.supported_locales.collect do |locale_code|
          current_instance.supported_locales_map[locale_code]
        end
      end

      def supported_language_codes(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.supported_locales.collect do |locale_code|
          current_instance.supported_locales_map[locale_code].language.code
        end
      end

      def active_locale_codes(key = nil)
        return self.instance.active_locales unless key
        return self.instances(key).active_locales
      end

      def active_locales(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.active_locales.collect do |locale_code|
          current_instance.active_locales_map[locale_code]
        end
      end

      def active_language_codes(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.active_locales.collect do |locale_code|
          current_instance.active_locales_map[locale_code].language.code
        end
      end

      def inactive_locale_codes(key = nil)
        return self.instance.supported_locales - self.instance.active_locales unless key
        return self.instances(key).supported_locales - self.instances(key).active_locales
      end

      def inactive_locales(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        inactive_locale_codes(key).collect do |locale_code|
          current_instance.supported_locales_map[locale_code]
        end
      end

      def inactive_language_codes(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        inactive_locale_codes(key).collect do |locale_code|
          current_instance.supported_locales_map[locale_code].language.code
        end
      end

      def supported?(locale, key = nil)
        current_instance = key ? self.instances(key) : self.instance

        case locale
          when String
            supported_locale_codes(key).include?(locale) || supported_language_codes(key).include?(locale)
          when Globalize::Locale
          current_instance.supported_locales_map.values.any? {|l| l.code == locale.code}
        end
      end

      def supported(code, key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.supported_locales_map[code] || supported_language(code, key)
      end

      def supported_language(language_code, key = nil)
        current_instance = key ? self.instances(key) : self.instance
        supported_code = current_instance.supported_locales_map.keys.detect do |code|
          code[0..1] == language_code
        end
        current_instance.supported_locales_map[supported_code] if supported_code
      end

      alias_method :[], :supported

      def active(code, key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.active_locales_map[code] || active_language(code, key)
      end

      def active_language(language_code, key = nil)
        current_instance = key ? self.instances(key) : self.instance
        active_code = current_instance.active_locales_map.keys.detect do |code|
          code[0..1] == language_code
        end
        current_instance.active_locales_map[active_code] if active_code
      end

      def non_base(code, key = nil)
        current_instance = key ? self.instances(key) : self.instance
        return nil if code == base_locale_code(key) || code == base_language_code(key)
        current_instance.supported_locales_map[code] || non_base_language(code, key)
      end

      def non_base_language(language_code, key = nil)
        current_instance = key ? self.instances(key) : self.instance
        return nil if language_code == base_language_code(key)
        non_base_code = current_instance.supported_locales_map.keys.detect do |code|
          code[0..1] == language_code
        end
        current_instance.supported_locales_map[non_base_code] if non_base_code
      end

      def non_base?(locale, key = nil)
        case locale
          when String
            non_base_locale_codes(key).include?(locale) || non_base_language_codes(key).include?(locale)
          when Globalize::Locale
            non_base_locales(key).any? {|l| l.code == locale.code}
        end
      end

      def active?(locale, key = nil)
        current_instance = key ? self.instances(key) : self.instance
        case locale
          when String
            active_locale_codes(key).include?(locale) || active_language_codes(key).include?(locale)
          when Globalize::Locale
            current_instance.active_locales_map.values.any? {|l| l.code == locale.code}
        end
      end

      def inactive?(locale, key = nil)
        case locale
          when String
            inactive_locale_codes(key).include?(locale) || inactive_language_codes(key).include?(locale)
          when Globalize::Locale
            inactive_locales(key).any? {|l| l.code == locale.code}
        end
      end

      def base_locale(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.base_locale_object
      end

      def default_locale(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.default_locale_object
      end

      def base_locale_code(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.base_locale
      end

      def base_language_code(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.base_locale_object.language.code
      end

      def default_locale_code(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.default_locale
      end

      def default_language_code(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.default_locale_object.language.code
      end

      def base_english_name
        Globalize::Locale.base_language.english_name
      end

      def base_native_name
        Globalize::Locale.base_language.native_name
      end

      def default_english_name(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.default_locale_object.language.english_name
      end

      def default_native_name(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.default_locale_object.language.native_name
      end

      def non_base_locales(key = nil)
        current_instance = key ? self.instances(key) : self.instance
        current_instance.supported_locales.dup.delete_if {|locale_code| locale_code == base_locale_code(key)}.collect {|locale_code| current_instance.supported_locales_map[locale_code]}.compact
      end

      def non_base_locale_codes(key = nil)
        non_base_locales(key).collect {|locale| locale.to_s}
      end

      def non_base_language_codes(key = nil)
        non_base_locales(key).collect {|locale| locale.language.code}
      end

      def non_base_native_language_names(key = nil)
        non_base_locales(key).collect {|locale| locale.language.native_name}
      end

      def non_base_english_language_names(key = nil)
        non_base_locales(key).collect {|locale| locale.language.english_name}
      end

      def supported_native_language_names(key = nil)
        supported_locales(key).collect {|locale| locale.language.native_name}
      end

      def supported_english_language_names(key = nil)
        supported_locales(key).collect {|locale| locale.language.english_name}
      end

      def active_native_language_names(key = nil)
        active_locales(key).collect {|locale| locale.language.native_name}
      end

      def active_english_language_names(key = nil)
        active_locales(key).collect {|locale| locale.language.english_name}
      end

      def inactive_native_language_names(key = nil)
        inactive_locales(key).collect {|locale| locale.language.native_name}
      end

      def inactive_english_language_names(key = nil)
        inactive_locales(key).collect {|locale| locale.language.english_name}
      end
    end

    protected

      def setup
        @base_locale_object = Globalize::Locale.new(*locale_array_for(@base_locale))
        raise "Globalize base language undefined!" unless @base_locale_object.language

        Globalize::Locale.clear_cache
        Globalize::Locale.set_base_language(@base_locale_object.language)
        raise "Globalize base language undefined!" unless Globalize::Locale.base_language

        @supported_locales.unshift(@base_locale) unless @supported_locales.include? @base_locale
        @supported_locales_map = Hash[*@supported_locales.collect do |locale_code|
          locale = Globalize::Locale.new(*locale_array_for(locale_code))
          raise "Language for code: #{locale_code} doesn't exist! Check globalize tables." unless locale.language
          [locale_code, locale] if locale
        end.flatten]

        @active_locales.unshift(@base_locale) unless @active_locales.include? @base_locale
        @active_locales_map = Hash[*@active_locales.collect do |locale_code|
          raise "Globalize active locale code (#{locale_code}) not one of supported locales"  unless @supported_locales_map[locale_code]
          [locale_code, @supported_locales_map[locale_code]]
        end.flatten]

        raise "Globalize default locale not one of supported locales" unless @active_locales.include?(@default_locale)
        @default_locale_object = Globalize::Locale.new(*locale_array_for(@default_locale))
        raise "Globalize default language undefined!" unless @default_locale_object.language
      end

      def locale_array_for(locale)
        case locale
          when String
            locale.split('_')
          when Array
            locale
        end
      end
  end

  class ActiveLocales < SupportedLocales
    class << self
      alias_method :[], :active
    end
  end

  class NonBaseLocales < SupportedLocales
    class << self
      alias_method :[], :non_base
    end
  end
end
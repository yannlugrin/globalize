# This is the default Translator.
# It simply looks for all .rb files in RAILS_ROOT/config/locale/
# and eval() them. It also has support for productized apps and if SITE_ROOT
# is defined it will overwrite default values from RAILS_ROOT with those from
# SITE_ROOT.
#
# If you want to write your own translator, for example fetching data from a
# database or reading gettext files instead, you only need to implement
# the method load_locale_data(locale) which fills the @locales hash with data.

module Locale
  class DefaultTranslator < AbstractTranslator

    def load_locale_data(locale)
      @locales[locale] ||= {}

      def string(str)
        @cstr = str.to_s
        yield
        @cstr = nil
      end
      alias :str :string
      alias :s   :string
      
      def to(locale,str,*args)
        raise "The to-method must be inside a translate-block!" if @cstr.nil?
        @locales[locale.to_s] ||= {}
        @locales[locale.to_s][@cstr] = [str]
        args.each { |arg| @locales[locale.to_s][@cstr] << arg }
      end
      alias :t :to
      unless Object.const_defined? :MLR_LOCALE_PATH
        Object.const_set(:MLR_LOCALE_PATH, DEFAULT_MLR_LOCALE_PATH)
      end
      Dir.glob("#{RAILS_ROOT}/#{MLR_LOCALE_PATH}/*.rb") do |f|
        eval File.read(f)
      end
      if Object.const_defined?('SITE_ROOT') # Productized
        Dir.glob("#{SITE_ROOT}/#{MLR_LOCALE_PATH}/*.rb") do |f|
          eval File.read(f)
        end
      end
    end

  end
end

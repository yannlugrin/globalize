module Multilingual
  class DbViewTranslator # :nodoc:

    def initialize(language)
      @language = language
    end

    def fetch(key, num = nil, default = nil)
      ViewTranslation.fetch(key, num, default, @language)
    end

    def set(key, *translations)
      translations = translations.flatten.compact
      ViewTranslation.set(key, translations, @language)
    end

  end
end
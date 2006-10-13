module Multilingual
  class DbViewTranslator

    def initialize(language)
      @language = language
    end

    def fetch(key, num = nil, default = nil)
      key = key.to_s.gsub('_', ' ') if key.kind_of? Symbol

      # allows shortcut default calling
      if default.nil? && num.kind_of?(String)
        default = num
        num = nil
      end

      ViewTranslation.fetch(key, num, default, @language)
    end

    def set(key, *translations)
      translations = translations.flatten.compact
      ViewTranslation.set(key, translations, @language)
    end

  end
end
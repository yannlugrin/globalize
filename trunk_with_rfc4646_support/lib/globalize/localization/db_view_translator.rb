module Globalize # :nodoc:
  class DbViewTranslator
    include Singleton

    # The maximum size of the cache in kilobytes.
    # This is just a rough estimate, the cache can grow bigger than this figure.
    attr_accessor :max_cache_size

    attr_reader :cache_size, :cache_total_hits, :cache_total_queries

    def fetch(key, locale_or_language, default = nil, arg = nil, namespace = nil) # :nodoc:

      raise "[Globalize::DbViewTranslator]" +
      " Can't interpolate multiple numbers." if key.scan(/(%d)/).flatten.size > 1

      fallbacks = nil
      primary_subtag = nil

      case locale_or_language
        when Locale
          fallbacks = locale_or_language.fallbacks
          primary_subtag = locale_or_language.language.primary_subtag
          language = locale_or_language.language
        else
          language = locale_or_language
      end

      # use argument as pluralization number, if number
      #If within an array, get the first number in the array
      num = arg.kind_of?(Numeric) ? arg : nil
      num ||= arg.kind_of?(Array) ? arg.select {|e| e.kind_of?(Numeric)}.first : nil

      # if there's no translation, use default or original key
      real_default = default || key

      result = fetch_from_cache(key, language, real_default, num,
                                namespace, primary_subtag, fallbacks)

      if arg
        strings = []
        if arg.kind_of?(Array)
          strings = arg.select {|e| !e.kind_of?(Numeric)}
        end
        result.scan(/(%[s|d])/).flatten.each do |interpolation|
          case interpolation
            when '%s'
              value = arg.kind_of?(Array) ? strings.shift : arg
              result = result.sub('%s', value.to_s)
            when '%d'
              raise "[Globalize::DbViewTranslator]" +
              " Can't interpolate a non-number for %d." unless num
              result = result.sub('%d', num.to_s)
          end
        end
      else
        result
      end
      result
    end

    def set(key, language, translations, zero_form = nil, namespace = nil) # :nodoc:
      raise ArgumentError, "No language set" if !language
      if translations.kind_of? Array
        translations = [ zero_form ] + translations
      else
        translations = [ zero_form, translations ]
      end

      idx = 0
      translations.each do |translation|
        set_pluralized(key, language, idx, translation, namespace)
        idx += 1
      end
    end

    def set_pluralized(key, language, idx, translation, namespace = nil)
      invalidate_cache(key, language, idx, namespace)
      ViewTranslation.transaction do
        old_tr = ViewTranslation.pick(key, language, idx, namespace)
        if old_tr
          old_tr.update_attribute(:text, translation)
        else
          ViewTranslation.create!(:tr_key => key,
            :language_id => language.id, :pluralization_index => idx,
            :text => translation, :namespace => namespace)
        end
      end
    end

    # Returns the number of items in the cache.
    def cache_count
      @cache.size
    end

    # Resets the cache and its statistics -- for testing.
    def cache_reset
      cache_clear
      @cache_total_hits = 0
      @cache_total_queries = 0
    end

    private
      def fetch_view_translation(key, language, idx, namespace = nil)
        tr = nil
        ViewTranslation.transaction do
          tr = ViewTranslation.pick(key, language, idx, namespace)

          # fill in a nil record for missed translations report
          # do not report missing zero-forms -- they're optional
          if !tr && idx != 0
            tr = ViewTranslation.create!(:tr_key => key,
              :language_id => language.id, :pluralization_index => idx,
              :text => nil, :namespace => namespace)
          end
        end

        tr ? tr.text : nil
      end

      def cache_fetch(key, language, idx, namespace = nil)
        @cache_total_queries += 1
        cache_key = cache_key(key, language, idx, namespace)
        @cache_total_hits += 1 if @cache.has_key?(cache_key)
        @cache[cache_key]
      end

      def cache_add(key, language, idx, translation, namespace = nil)
        cache_clear if @cache_size > max_cache_size * 1024
        size = key.size + (translation.nil? ? 0 : translation.size)
        @cache_size += size
        @cache[cache_key(key, language, idx, namespace)] = translation
      end

      def invalidate_cache(key, language, idx, namespace = nil)
        tr = @cache.delete(cache_key(key, language, idx, namespace))
        size = key.size + (tr.nil? ? 0 : tr.size)
        @cache_size -= size
      end

      def cache_key(key, language, idx, namespace = nil)
        [ key, language.code, idx, namespace].compact.join(':')
      end

      def cache_hit_ratio
        @cache_total_hits / @cache_total_queries
      end

      def cache_clear
        @cache.clear
        @cache_size = 0
      end

      def initialize
        @cache = {}
        @cache_size = 0
        @cache_total_hits = 0
        @cache_total_queries = 0

        # default cache size is 8mb
        @max_cache_size = 8192
      end

      def fetch_from_cache(key, language, real_default, num,
                           namespace = nil, primary_subtag = nil, fallbacks = nil)
        return real_default if language.nil?

        zero_form   = num == 0
        plural_idx  = language.plural_index(num) # language-defined plural form
        zplural_idx = zero_form ? 0 : plural_idx # takes zero-form into account

        cached = cache_fetch(key, language, zplural_idx, namespace)
        if cached
          result = cached
        else
          result = fetch_view_translation(key, language, zplural_idx, namespace)

          # set to plural_form if no zero-form exists
          result ||= fetch_view_translation(key, language, plural_idx, namespace) if zero_form

          unless result
            languages = []
            languages = fallbacks.collect {|f| f.language } if fallbacks
            languages += [Language.pick(primary_subtag)] if primary_subtag && language.code != primary_subtag
            languages = languages.flatten.uniq.compact

            unless languages.empty?
              languages.each do |lang|
                language = lang
                result = fetch_from_cache(key, language, real_default, num, namespace)
                break if result && result != real_default
              end
            end
          end

          cache_add(key, language, zplural_idx, result, namespace)
        end
        result ||= real_default
      end

  end
end

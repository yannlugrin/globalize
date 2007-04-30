module Globalize
  class Language < ActiveRecord::Base # :nodoc:
    set_table_name "globalize_languages"

    validates_presence_of :tag, :primary_subtag, :english_name

    validates_uniqueness_of :tag

    validates_length_of :pluralization, :maximum => 200, :if => :pluralization
    validates_format_of :pluralization, :with => /^[c=\d?:%!<>&|() ]+$/, :if => :pluralization,
      :message => " has invalid characters. Allowed characters are: " +
        "'c', '=', 0-9, '?', ':', '%', '!', '<', '>', '&', '|', '(', ')', ' '."

    def self.reloadable?; false end

    def after_initialize
      if !pluralization.nil? && pluralization.size > 200
        raise SecurityError, "Pluralization field for #{self.english_name} language " +
          "contains potentially harmful code. " +
          "Must be less than 200 characters in length. Was #{pluralization.size} characters."
      end

      if !pluralization.nil? && pluralization !~ /^[c=\d?:%!<>&|() ]+$/
        raise SecurityError, "Pluralization field ('#{pluralization}') for #{self.english_name} language " +
          "contains potentially harmful code. " +
          "Must only use the characters: 'c', '=', 0-9, '?', ':', " +
          "'%', '!', '<', '>', '&', '|', '(', ')', ' '."
      end
    end

    def self.pick(rfc_or_language_tag)
      tag = nil

      case rfc_or_language_tag
        when String
          tag = rfc_or_language_tag
          rfc_or_language_tag = RFC_4646.parse(tag)
        when RFC_4646
          tag = rfc_or_language_tag.tag
        when RFC_3066
          tag = rfc_or_language_tag.language
          $stderr.puts "Supplying an RFC_3066 instance to Language.pick(rfc_or_tag) is deprecated! Use  a valid rfc_4646 language tag or an instance of RFC_4646)."
          #$stdout.puts caller.inspect unless $stderr.kind_of?(StringIO)
      end

      lang = find_by_tag(tag)
      return lang if lang

      #as we don't know wether the string argument was meant to be a valid
      #rfc_4646 or rfc_3066 tag we throw an exception and let them decide.
      if rfc_or_language_tag.kind_of?(RFC_4646) && rfc_or_language_tag.tag.include?('-')
        raise ArgumentError, <<-EOM
        Language.pick now only accepts a valid rfc_4646 language tag.
        If you supplied a tag with this format {language_code}_{country_code}
        e.g en-US
        it was taken to be the American regional variant of the English language
        and for this reason may not have been found in the database.
        Drop the country code and just use 'en' if you meant to just select the english language.
        If you really did mean to specify #{tag} as a valid rfc_4646 tag then this tag
        is NOT available in the database.
        You can add it via: 'Globalize::Language.add()'
        EOM
      else
        raise ArgumentError, "Tag '#{tag}' not available in the database. You can add it via: 'Globalize::Language.add()'"
      end

      lang
    end

=begin
  Create a new Language.
  Syntax:
    Language.add('en-AU','en','English (Australia)', 'Ozzie', 'ltr', 'c == 1 ? 1 : 2')
    or
    locale_en = Locale.active
    Language.add('en-AU',locale_en.language) #The locale's language is used as a template for the new Language
    or
    Language.add('en-AU',locale_en, 'English (Australia)', 'Ozzie')
    #The supplied locale's language is used as a template but attributes can be overriden
=end
    def self.add(tag, primary_subtag_or_template, english_name=nil,
                 native_name=nil, direction=nil, pluralization=nil,
                 primary_subtag = nil)

      RFC_4646.parse(tag, true)
      options = {:tag => tag}
      case primary_subtag_or_template
        when Locale, Language
          template_options = {}
          case primary_subtag_or_template
            when Locale
              template_options = primary_subtag_or_template.language.attributes
            when Language
              template_options = primary_subtag_or_template.attributes
          end

          template_options.merge!({:english_name => english_name}) if english_name
          template_options.merge!({:native_name => native_name}) if native_name
          template_options.merge!({:direction => direction}) if direction
          template_options.merge!({:pluralization => pluralization}) if pluralization
          template_options.merge!({:primary_subtag => primary_subtag}) if primary_subtag
          options.reverse_merge!(template_options)
        else
        options.merge(:primary_subtag => primary_subtag_or_template,
                      :english_name => english_name,
                      :native_name => native_name,
                      :direction => direction,
                      :pluralization => pluralization)
      end
      self.create!(options)
    end

    def code; tag; end

    def dbcode; tag.gsub('-','_'); end

    def method_missing(method_id, *args, &block)
      err_msg = ":#{method_id.id2name}() is deprecated! It is no longer an attribute of Globalize::Language."

      begin
        super(method_id, *args, &block)
      rescue NoMethodError
        case method_id
          when :iso_639_1, :iso_639_2, :iso_639_3, :rfc_3066
            $stderr.puts err_msg << " Use 'tag'."
            tag
          when :english_name_locale, :english_name_modifier, :native_name_locale, :native_name_modifier, :macro_language , :scope
            $stderr.puts err_msg << " It has no equivalent."
            nil
          else
            raise NoMethodError.new(
            "undefined method `#{method_id.id2name}' for " +
            "#{self.inspect}:#{self.class.name}"
            )
        end
      end
    end

    def xxx_code=(new_code)
      if new_code =~ /-/
        self.rfc_3066 = new_code
      else
        raise ArgumentError,
          "code must be in rfc_3066 format, with a hyphen character; was #{new_code}"
      end
    end

    def native_name; self['native_name'] || self['english_name'] end

    def ==(other)
      return false if !other.kind_of? Language
      self.code == other.code
    end

    def plural_index(num)

      # number is not defined, so we assume no pluralization
      return 1 if num.nil?

      c = num
      expr = pluralization || 'c == 1 ? 2 : 1'

      instance_eval(expr)
    end

    def to_s;    english_name end
    def inspect; english_name end

  end
end
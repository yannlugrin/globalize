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

    def self.pick(rfc)
      rfc = RFC_4646.parse(rfc) if rfc.kind_of? String
      lang = find_by_tag(rfc.language)
      return lang if lang

      if rfc.tag.include? '-'
        raise <<-'EOM'
        Language.pick now only accepts a valid rfc_4646 tag.
        If you supplied a tag with this format {language_code}_{country_code}
        e.g es-ES
        it was taken to be the Spanish regional variant of the Spanish language
        and for this reason may not have been found in the database.
        Drop the country code and just use 'es' if you meant to select the spanish language .
        If you really did mean to specify es-ES as a valid rfc_4646 tag then this tag
        is NOT available in the database.
        You can add it via:
        EOM
      else
        raise "Tag not available in the database. You can add it via:"
      end

      lang
    end

    def code; tag; end

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
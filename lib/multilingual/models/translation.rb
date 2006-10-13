module Multilingual
  # Represents a translation in the DB. This class is mostly for internal use of
  # the Multilingual plugin, except for the initialize_supported_language class
  # method.
  class Translation < ActiveRecord::Base
    # Initializes translation db for a new language by copying base translations
    # from base language. Will throw an exception if there are any entries for 
    # the new language.
    def self.initialize_supported_language(language)
      old = Translation.find(:first, :conditions => [ "language_id = ?", language.id ])
      raise TranslationTrampleError, "Can't add language (#{language.english_name} " +
        "that already has entries" if !old.nil?
      sql = "INSERT INTO translations (table_name, item_id, facet, language_id, text) " +
      "SELECT table_name, item_id, facet, ? AS language_id, text " +
      "FROM translations " +
      "WHERE language_id = ?"
      sql = sanitize_sql([ sql, language.id, Language.base_language.id ])
      connection.insert(sql, "Add newly supported language: #{language.english_name}")
    end
  end
end
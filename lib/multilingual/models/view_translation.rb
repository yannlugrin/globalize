module Multilingual
  # Represents a view translation in the DB, which is a translation of a string
  # in the rails application itself. This includes error messages, controllers,
  # views, and flashes, but not database content.
  class ViewTranslation < Translation # :nodoc:
    serialize :text, Array

    def self.pick(key, language)
      find_by_tr_key_and_language_id(key, language.id)      
    end

    def self.fetch(key, num, default, language)
      tr = nil
      transaction do
        tr = pick(key, language)

        # fill in a nil record for missed translations report
        if !tr
          tr = create!(:tr_key => key, :language_id => language.id, 
            :text => nil)
        end
      end

      idx = language.plural_index(num)


      # if there's no correct pluralization, use default (first)
      # if there's no translation, use default or original key      
      default ||= key
      result = tr.text ? tr.text[idx] || tr.text.first : default

      result.gsub('%d', num.to_s)
    end

    def self.set(key, translations, language)
      transaction do
        old_tr = pick(key, language)
        if old_tr
          old_tr.update_attribute(text, translations)
        else
          create!(:tr_key => key, :language_id => language.id, 
            :text => translations)
        end
      end 
    end

  end
end
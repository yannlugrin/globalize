module Globalize
  class Country < ActiveRecord::Base # :nodoc:
    set_table_name "globalize_countries"

    def self.reloadable?; false end

    def self.pick(rfc)
      tag = nil
      # assume it's a country code string
      if rfc.kind_of?(String)
        tag = rfc
        country = find_by_code(tag)
      elsif rfc.kind_of?(RFC_3066)
        tag = rfc.country
        country = tag ? find_by_code(tag) : nil
      else
        raise ArgumentError, "argument must be String or RFC_3066 object (WARNING!: The use of RFC_3066 is deprecated)"
      end

      country ? country : raise(ArgumentError, "Tag ('#{tag}') not available in the database. You can add it via:")
    end

    def number_grouping_scheme
      attr = read_attribute(:number_grouping_scheme)
      attr ? attr.intern : nil
    end
  end
end
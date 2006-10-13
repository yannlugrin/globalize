module Multilingual
  class Country < ActiveRecord::Base
    set_table_name "multilingual_countries"

    def self.pick(rfc)

      # assume it's a country code string
      if rfc.kind_of?(String)
        find_by_code(rfc)  
      elsif rfc.kind_of?(RFC_3066)
        rfc.country ? find_by_code(rfc.country) : nil
      else
        raise ArgumentError, "argument must be String or RFC_3066 object"
      end
    end

  end
end

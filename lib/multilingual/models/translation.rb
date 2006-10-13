module Multilingual # :nodoc:
  class Translation < ActiveRecord::Base  # :nodoc:
    set_table_name "multilingual_translations"    

    belongs_to :language
  end
end
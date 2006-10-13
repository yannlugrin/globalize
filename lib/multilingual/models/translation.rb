module Multilingual # :nodoc:
  # Abstract base class for translations -- used internally.
  class Translation < ActiveRecord::Base
    set_table_name "multilingual_translations"    

    belongs_to :language
  end
end
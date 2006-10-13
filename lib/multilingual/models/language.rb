class Language < ActiveRecord::Base
  validates_uniqueness_of :iso_639_1
  validates_presence_of :iso_639_1, :english_name

  # language to be used for translation, set per request
  @@active_language_code = nil

  # default language to be used for translation, set per application
  @@default_language_code = nil  

  # this is the language which has complete coverage in the db
  @@base_language_code = nil     

  def self.active_language_code 
    @@active_language_code || self.default_language_code
  end
  def self.active_language_code=(lang); @@active_language_code = lang; end

  def self.default_language_code
    @@default_language_code or 'en' 
  end
  def self.default_language_code=(lang); @@default_language_code = lang; end

  def self.base_language_code
    @@base_language_code or self.default_language_code or 'en'
  end
  def self.base_language_code=(lang); @@base_language_code = lang; end

  def self.pick(code); self.find_by_code(code); end

  def self.active_language; pick(self.active_language_code); end
  def self.base_language; pick(self.base_language_code); end

  def self.find_by_code(code)
    if code.size == 2
      find_by_iso_639_1(code)
    elsif code.size == 3
      find_by_iso_639_3(code)
    else
      raise ArgumentError, "language code must be 2 or 3 characters long"
    end
  end

  def code; iso_639_1 or iso_639_3; end
  
  def code=(new_code)
    if new_code.size == 2
      self.iso_639_1 = new_code
    else
      raise ArgumentError, "iso 639 part 1 code must be 2 or 3 " + 
        "characters long, was #{new_code}"
    end
  end

  def ==(other)
    return false if !other.kind_of? Language
    self.code == other.code
  end

  def self.all
    self.find(:all, :order => "position")
  end
end

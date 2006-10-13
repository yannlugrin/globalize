# Hook up core extenstions (need to define them as main level, hence 
# the :: prefix)
class ::String  
  include Multilingual::CoreExtensions::String
end

class ::Symbol  
  include Multilingual::CoreExtensions::Symbol
end

class ::Object  
  include Multilingual::CoreExtensions::Object
end

class ::Fixnum
  alias :unlocalized :to_s
  include Multilingual::CoreExtensions::Integer 

  # Overrides +to_s+ to format number correctly for currently set locale.
  def to_s( base = 10 )
    localized(base)
  end
end

class ::Bignum
  alias :unlocalized :to_s
  include Multilingual::CoreExtensions::Integer

  # Overrides +to_s+ to format number correctly for currently set locale.
  def to_s( base = 10 )
    localized(base)
  end
end

class ::Float
  alias :unlocalized :to_s
  include Multilingual::CoreExtensions::Float  

  # Overrides +to_s+ to format number correctly for currently set locale.
  def to_s
    localized
  end
end

class ::Time
  alias :unlocalized_strftime :strftime
  include Multilingual::CoreExtensions::Time

  # Overrides +strftime+ to format and translate date correctly for currently set locale.
  def strftime(format)
    localized_strftime(format)      
  end
end

class ::Date
  alias :unlocalized_strftime :strftime
  include Multilingual::CoreExtensions::Date

  # Overrides +strftime+ to format and translate date correctly for currently set locale.
  def strftime(format)
    localized_strftime(format)      
  end
end

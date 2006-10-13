# Use dummy methods when multilingual support isn't available

class String
  def t(*ignored)
    self
  end
end

class Symbol
  def t(*ignored)
    self.to_s
  end
  def %(*ignored)
    self.to_s
  end
end

class Object
  def _(str)
    str.to_s
  end
end

module Locale
  def self.set(*ignored)
    false
  end
  def self.current
    'en_US'
  end
  def self.reload!
    nil
  end
end

# These don't depend on ruby-locale
require "#{MLR_ROOT}/iso"

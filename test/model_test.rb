require File.dirname(__FILE__) + '/test_helper'

class ModelTest < Test::Unit::TestCase
  include Multilingual

  fixtures :multilingual_languages

  def setup
  end

  def test_language
    rfc = RFC_3066.parse 'en-US'
    lang = Language.pick(rfc)
    assert_equal 'en', lang.code
  end

end

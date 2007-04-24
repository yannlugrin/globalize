require File.dirname(__FILE__) + '/test_helper'

class RFC_3066Test < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages, :globalize_countries

  def setup
  end

  def test_rfc_3066
    rfc = RFC_3066.parse 'en-US'
    assert_equal 'en', rfc.language
    assert_equal 'US', rfc.country
    assert_equal 'en-US', rfc.locale
  end

end

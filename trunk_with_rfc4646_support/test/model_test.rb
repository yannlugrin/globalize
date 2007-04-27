require File.dirname(__FILE__) + '/test_helper'

class ModelTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages

  def setup
  end

  def test_language
    rfc = RFC_3066.parse 'en-US'
    std_err_msg = "Supplying an RFC_3066 instance to Language.pick(rfc_or_tag) is deprecated! Use  a valid rfc_4646 language tag or an instance of RFC_4646).\n"

    lang = nil
    assert_stderr_includes std_err_msg do
      lang = Language.pick(rfc)
    end
    assert_equal 'en', lang.code
  end

end

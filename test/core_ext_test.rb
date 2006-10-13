require File.dirname(__FILE__) + '/test_helper'

class CoreExtTest < Test::Unit::TestCase
  include Multilingual
  fixtures :multilingual_languages, :multilingual_countries, :multilingual_translations

  def setup
    Locale.set("en-US")
  end

  def test_numbers
    assert_equal "23,123,456", 23123456.to_s
    assert_equal "23,123,456.45625", 23123456.45625.to_s
    Locale.set("de-DE")
    assert_equal "23.123.456", 23123456.to_s
    assert_equal "23.123.456,45625", 23123456.45625.to_s
  end

  def test_times
    t = Time.mktime(2005, 10, 17, 0, 0, 0, 0)
    assert_equal "Mon Oct 17", t.strftime("%a %b %d")
    Locale.set("he-IL")
    assert_equal "יום ב', 17 אוק 2005", t.strftime("%a, %d %b %Y")
    assert_equal "17.10.2005", t.strftime("%c")
  end

  def test_dates
    d = Date.new(2005, 10, 17)
    assert_equal "Mon Oct 17", d.strftime("%a %b %d")
    Locale.set("he-IL")
    assert_equal "יום ב', 17 אוק 2005", d.strftime("%a, %d %b %Y")
    assert_equal "17.10.2005", d.strftime("%c")
  end

  def teardown
    Locale.set("en-US")
  end
end

require File.dirname(__FILE__) + '/test_helper'

class ViewTranslationTest < Test::Unit::TestCase
  include Multilingual

  fixtures :multilingual_languages, :multilingual_countries, :multilingual_translations

  def setup
    Multilingual::Locale.set("en-US")
    Multilingual::Locale.set_base_language("en-US")
  end

  def test_translate
    assert_equal "This is the default", "This is the default".t
    Locale.set("he-IL")
    assert_equal "This is the default", "This is the default".t
    assert_equal "ועכשיו בעברית", "And now in Hebrew".t
  end

  def test_plural
    Locale.set("pl-PL")
    assert_equal "1 plik", "%d file" / 1
    assert_equal "2 pliki", "%d file" / 2
    assert_equal "3 pliki", "%d file" / 3
    assert_equal "4 pliki", "%d file" / 4

    assert_equal "5 plików", "%d file" / 5
    assert_equal "8 plików", "%d file" / 8
    assert_equal "13 plików", "%d file" / 13
    assert_equal "21 plików", "%d file" / 21

    assert_equal "22 pliki", "%d file" / 22
    assert_equal "23 pliki", "%d file" / 23
    assert_equal "24 pliki", "%d file" / 24

    assert_equal "25 plików", "%d file" / 25
    assert_equal "31 plików", "%d file" / 31
  end

  def test_aliases
    Locale.set("he-IL")
    assert_equal "ועכשיו בעברית", "And now in Hebrew".translate
    assert_equal "ועכשיו בעברית", _("And now in Hebrew")    
  end

  def test_missed_report
    Locale.set("he-IL")
    assert_nil ViewTranslation.find(:first, 
      :conditions => %q{language_id = 2 AND tr_key = "not in database"})
    assert_equal "not in database", "not in database".t
    result = ViewTranslation.find(:first, 
      :conditions => %q{language_id = 2 AND tr_key = "not in database"})
    assert_not_nil result, "There should be a record in the db with nil text"
    assert_nil result.text
  end

  # for when language doesn't have a translation
  def test_default_number_substitution
    Locale.set("pl-PL")
    assert_equal "There are 0 translations for this", 
      "There are %d translations for this" / 0    
  end

  # for when language only has one pluralization form for translation
  def test_default_number_substitution2
    Locale.set("he-IL")
    assert_equal "יש לי 5 קבצים", "I have %d files" / 5    
  end

  def test_symbol
    Locale.set("he-IL")
    assert_equal "ועכשיו בעברית", :And_now_in_Hebrew.t
    assert_equal "this is the default", :bogus_translation.t("this is the default")
    assert_equal "0 translations", 
      "There are %d translations for test_symbol".t(0, "%d translations")    
  end

  def test_syntax_error
    Locale.set("ur")
    assert_raise(SyntaxError) { "I have %d bogus numbers" / 5 }
  end

  def test_illegal_code
    assert_raise(SecurityError) { Locale.set("ba") }
  end

  def test_overflow_code
    assert_raise(SecurityError) { Locale.set("tw") }
  end

end
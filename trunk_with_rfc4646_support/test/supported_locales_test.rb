require File.dirname(__FILE__) + '/test_helper'

class SupportedLocalesTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages, :globalize_countries

  def setup
    @supported_locales = ['es_ES', 'he_IL']
  end

  def test_base_locale_default_is_en_US
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert_equal 'en', SupportedLocales.base_language_code
    assert_equal 'US', SupportedLocales.base_locale.country.code
    assert_equal 'en_US', SupportedLocales.base_locale_code
    assert_equal 'en', SupportedLocales.base_locale.code
    assert_equal 'English', SupportedLocales.base_english_name
    assert_equal 'English', SupportedLocales.base_native_name
  end

  def test_base_locale_is_automatically_added_to_supported_locales_if_not_present
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales, 'pl_PL')
    assert_equal 'pl', SupportedLocales.base_language_code
    assert_equal 'PL', SupportedLocales.base_locale.country.code
    assert_equal 'pl_PL', SupportedLocales.base_locale_code
    assert_equal 'pl', SupportedLocales.base_locale.code
    assert_equal 'język polski', SupportedLocales.base_native_name
    assert_equal 'Polish', SupportedLocales.base_english_name

    assert SupportedLocales.supported?('pl_PL')
    assert SupportedLocales.supported?('pl')
    assert SupportedLocales.supported_locales.any? {|l| l.code == 'pl'}
    assert SupportedLocales.supported_locale_codes.any? {|l| l == 'pl_PL'}
    assert SupportedLocales.supported_english_language_names.any? {|l| l == 'Polish'}
    assert SupportedLocales.supported_native_language_names.any? {|l| l == 'język polski'}
  end

  def test_base_locale_is_automatically_added_to_active_locales_if_not_present
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales, 'pl_PL')

    assert SupportedLocales.active?('pl_PL')
    assert SupportedLocales.active?('pl')
    assert SupportedLocales.active_locales.any? {|l| l.code == 'pl'}
    assert SupportedLocales.active_locale_codes.any? {|l| l == 'pl_PL'}
    assert SupportedLocales.active_english_language_names.any? {|l| l == 'Polish'}
    assert SupportedLocales.active_native_language_names.any? {|l| l == 'język polski'}
  end

  def test_default_locale_default_is_base_locale
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert_equal SupportedLocales.base_language_code, SupportedLocales.default_language_code
    assert_equal SupportedLocales.base_locale.country.code, SupportedLocales.default_locale.country.code
    assert_equal SupportedLocales.base_locale_code, SupportedLocales.default_locale_code
    assert_equal SupportedLocales.base_locale.code, SupportedLocales.default_locale.code
    assert_equal SupportedLocales.base_english_name, SupportedLocales.default_english_name
    assert_equal SupportedLocales.base_native_name, SupportedLocales.default_native_name
  end

  def test_supported_locales_includes_base_locale
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert_equal ['en_US','es_ES', 'he_IL'], SupportedLocales.supported_locale_codes
    assert_equal ['en','es', 'he'], SupportedLocales.supported_locales.collect {|l| l.code}
    assert_equal ['en','es', 'he'], SupportedLocales.supported_language_codes
    assert SupportedLocales.supported?('en_US')
    assert SupportedLocales.supported?('en')
    assert SupportedLocales.supported?(Locale.new('en','US'))
    assert_equal ['English','Spanish','Hebrew'], SupportedLocales.supported_english_language_names
    assert_equal ['English','Español','עברית'], SupportedLocales.supported_native_language_names
  end

  def test_active_locales_defaults_to_supported_locales
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert_equal ['en_US','es_ES', 'he_IL'], SupportedLocales.active_locale_codes
    assert_equal ['en','es', 'he'], SupportedLocales.active_locales.collect {|l| l.code}
    assert_equal ['en','es', 'he'], SupportedLocales.active_language_codes
    assert SupportedLocales.active?('en_US')
    assert SupportedLocales.active?('en')
    assert SupportedLocales.active?(Locale.new('en','US'))
    assert_equal ['English','Spanish','Hebrew'], SupportedLocales.active_english_language_names
    assert_equal ['English','Español','עברית'], SupportedLocales.active_native_language_names
  end

  def test_non_base_locales_shouldnt_include_base_locale
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert !SupportedLocales.non_base_locales.any? {|l| l.code == 'en'}
    assert ['es_ES', 'he_IL'], SupportedLocales.non_base_locale_codes
    assert ['es', 'he'], SupportedLocales.non_base_language_codes
    assert_equal ['Spanish','Hebrew'], SupportedLocales.non_base_english_language_names
    assert_equal ['Español','עברית'], SupportedLocales.non_base_native_language_names
    assert !SupportedLocales.non_base?('en_US')
    assert !SupportedLocales.non_base?('en')
    assert !SupportedLocales.non_base?(Locale.new('en','US'))
  end

  def test_non_base_locales_should_only_include_supported_locales
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales,'en_US', ['es_ES'])
    assert !SupportedLocales.non_base_locales.any? {|l| l.code == 'en'}
    assert SupportedLocales.non_base_locales.any? {|l| l.code == 'he'}
    assert ['es_ES','he_IL'], SupportedLocales.non_base_locale_codes
    assert ['es','he'], SupportedLocales.non_base_language_codes
    assert_equal ['Spanish','Hebrew'], SupportedLocales.non_base_english_language_names
    assert_equal ['Español','עברית'], SupportedLocales.non_base_native_language_names
    assert !SupportedLocales.non_base?('en_US')
    assert !SupportedLocales.non_base?('en')
    assert !SupportedLocales.non_base?(Locale.new('en','US'))
    assert SupportedLocales.non_base?('es_ES')
    assert SupportedLocales.non_base?('es')
    assert SupportedLocales.non_base?(Locale.new('es','ES'))
    assert SupportedLocales.non_base?('he_IL')
    assert SupportedLocales.non_base?('he')
    assert SupportedLocales.non_base?(Locale.new('he','IL'))
  end

  def test_default_locale_should_be_supported_and_active
    SupportedLocales.clear

    assert_nothing_raised do
      SupportedLocales.define(@supported_locales,'en_US', ['es_ES'], 'es_ES')
      assert_equal 'es', SupportedLocales.default_language_code
      assert_equal 'ES', SupportedLocales.default_locale.country.code
      assert_equal 'es_ES', SupportedLocales.default_locale_code
      assert_equal 'es', SupportedLocales.default_locale.code
      assert_equal 'Spanish', SupportedLocales.default_english_name
      assert_equal 'Español', SupportedLocales.default_native_name
    end

    assert_raise RuntimeError do
      SupportedLocales.clear
      SupportedLocales.define(@supported_locales,'en_US', ['es_ES'], 'he_IL')
      SupportedLocales.instance
    end

    assert_nothing_raised do
      SupportedLocales.clear
      SupportedLocales.define(@supported_locales,'en_US', ['es_ES'], 'en_US')
      SupportedLocales.instance
    end
  end

  def test_active_locales_should_be_subset_of_supported_locales

    assert_nothing_raised do
      SupportedLocales.clear
      SupportedLocales.define(['es_ES','he_IL','pl_PL'],'en_US', ['es_ES','he_IL'])
      assert SupportedLocales.active_locale_codes.all? {|l| SupportedLocales.supported_locale_codes.include?(l)}
      assert SupportedLocales.active_locales.all? {|l| SupportedLocales.supported_locales.include?(l)}
      assert SupportedLocales.active_language_codes.all? {|l| SupportedLocales.supported_language_codes.include?(l)}
      assert SupportedLocales.active_english_language_names.all? {|l| SupportedLocales.supported_english_language_names.include?(l)}
      assert SupportedLocales.active_native_language_names.all? {|l| SupportedLocales.supported_native_language_names.include?(l)}
    end

    assert_raise RuntimeError do
      SupportedLocales.clear
      SupportedLocales.define(@supported_locales,'en_US', ['pl_PL'])
      SupportedLocales.instance
    end
  end

  def test_inactive_locales_should_not_be_subset_of_active_locales
    assert_nothing_raised do
      SupportedLocales.clear
      SupportedLocales.define(['es_ES','he_IL','pl_PL'],'en_US', ['es_ES','he_IL'])
      assert SupportedLocales.inactive_locale_codes.all? {|l| !SupportedLocales.active_locale_codes.include?(l)}
      assert SupportedLocales.inactive_locales.all? {|l| !SupportedLocales.active_locales.include?(l)}
      assert SupportedLocales.inactive_language_codes.all? {|l| !SupportedLocales.active_language_codes.include?(l)}
      assert SupportedLocales.inactive_english_language_names.all? {|l| !SupportedLocales.active_english_language_names.include?(l)}
      assert SupportedLocales.inactive_native_language_names.all? {|l| !SupportedLocales.active_native_language_names.include?(l)}
    end
  end

  def test_inactive_locales_should_be_subset_of_supported_locales
    assert_nothing_raised do
      SupportedLocales.clear
      SupportedLocales.define(['es_ES','he_IL','pl_PL'],'en_US', ['es_ES','he_IL'])
      assert SupportedLocales.inactive_locale_codes.all? {|l| SupportedLocales.supported_locale_codes.include?(l)}
      assert SupportedLocales.inactive_locales.all? {|l| SupportedLocales.supported_locales.include?(l)}
      assert SupportedLocales.inactive_language_codes.all? {|l| SupportedLocales.supported_language_codes.include?(l)}
      assert SupportedLocales.inactive_english_language_names.all? {|l| SupportedLocales.supported_english_language_names.include?(l)}
      assert SupportedLocales.inactive_native_language_names.all? {|l| SupportedLocales.supported_native_language_names.include?(l)}
    end
  end

  def test_supported_shortcut
    SupportedLocales.clear
    SupportedLocales.define(['es_ES','he_IL','pl_PL'],'en_US', ['es_ES','he_IL'])
    assert_equal 'en', SupportedLocales['en_US'].code
    assert_equal 'en', SupportedLocales['en'].code
    assert_equal 'es', SupportedLocales['es_ES'].code
    assert_equal 'es', SupportedLocales['es'].code
    assert_equal 'he', SupportedLocales['he_IL'].code
    assert_equal 'he', SupportedLocales['he'].code
    assert_equal 'pl', SupportedLocales['pl_PL'].code
    assert_equal 'pl', SupportedLocales['pl'].code

    assert_nil SupportedLocales['fr']
    assert_nil SupportedLocales['fr_FR']
  end

  def test_active_shortcut
    SupportedLocales.clear
    SupportedLocales.define(['es_ES','he_IL','pl_PL'],'en_US', ['es_ES','he_IL'])
    assert_equal 'en', ActiveLocales['en_US'].code
    assert_equal 'en', ActiveLocales['en'].code
    assert_equal 'es', ActiveLocales['es_ES'].code
    assert_equal 'es', ActiveLocales['es'].code
    assert_equal 'he', ActiveLocales['he_IL'].code
    assert_equal 'he', ActiveLocales['he'].code

    assert_nil ActiveLocales['pl_PL']
    assert_nil ActiveLocales['pl']
    assert_nil ActiveLocales['fr']
    assert_nil ActiveLocales['fr_FR']
  end

  def test_non_base_shortcut
    SupportedLocales.clear
    SupportedLocales.define(['es_ES','he_IL','pl_PL'],'en_US', ['es_ES','he_IL'])
    assert_equal 'es', NonBaseLocales['es_ES'].code
    assert_equal 'es', NonBaseLocales['es'].code
    assert_equal 'he', NonBaseLocales['he_IL'].code
    assert_equal 'he', NonBaseLocales['he'].code
    assert_equal 'pl', NonBaseLocales['pl_PL'].code
    assert_equal 'pl', NonBaseLocales['pl'].code

    assert_nil NonBaseLocales['en_US']
    assert_nil NonBaseLocales['en']
    assert_nil NonBaseLocales['fr']
    assert_nil NonBaseLocales['fr_FR']
  end
end
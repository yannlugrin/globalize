require File.dirname(__FILE__) + '/test_helper'

class LocaleTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages, :globalize_countries

  def setup
  end

  def test_setting_valid_locale_with_lang_and_country_arguments
    assert_nothing_raised do
      Locale.clear_cache(true)
      assert !Locale.active?

      loc = nil

      loc = Locale.set('en', 'US')
      assert_equal 'en', loc.language.code
      assert_equal 'US', loc.country.code
      assert_equal 'English', loc.language.english_name
      assert_equal 'United States', loc.country.english_name
      assert_equal 'en',      loc.rfc.tag
      assert_equal 'en',      loc.rfc.primary
      assert_nil              loc.rfc.region

      assert Locale.active?

      loc = Locale.set('en-GB', 'GB')
      assert_equal 'en-GB', loc.language.code
      assert_equal 'GB', loc.country.code
      assert_equal 'English (UK)', loc.language.english_name
      assert_equal 'United Kingdom',   loc.country.english_name
      assert_equal 'en-GB',      loc.rfc.tag
      assert_equal 'en',      loc.rfc.primary
      assert_equal 'GB',      loc.rfc.region

      loc = Locale.set('en-GB', 'US')
      assert_equal 'en-GB', loc.language.code
      assert_equal 'US', loc.country.code

      loc = Locale.set('es', 'ES')
      assert_equal 'es', loc.language.code
      assert_equal 'ES', loc.country.code
      assert_equal 'Spanish', loc.language.english_name
      assert_equal 'Spain',   loc.country.english_name
      assert_equal 'es',      loc.rfc.tag
      assert_equal 'es',      loc.rfc.primary
      assert_nil              loc.rfc.region

      loc = Locale.set('es', 'MX')
      assert_equal 'es', loc.language.code
      assert_equal 'MX', loc.country.code

      loc = Locale.set('es-MX', 'MX')
      assert_equal 'es-MX', loc.language.code
      assert_equal 'MX', loc.country.code
      assert_equal 'Spanish (Mexico)', loc.language.english_name
      assert_equal 'Mexico',  loc.country.english_name
      assert_equal 'es-MX',   loc.rfc.tag
      assert_equal 'es',      loc.rfc.primary
      assert_equal 'MX',      loc.rfc.region

      loc = Locale.set('es-MX', 'AR')
      assert_equal 'es-MX', loc.language.code
      assert_equal 'AR', loc.country.code
    end
  end

  def test_setting_valid_locale_with_lang_argument_and_country_picking_from_region
    assert_nothing_raised do
      Locale.clear_cache(true)

      loc = nil
      loc = Locale.set('en-US')
      assert_equal 'en-US', loc.language.code
      assert_equal 'US', loc.country.code

      loc = Locale.set('en-GB')
      assert_equal 'en-GB', loc.language.code
      assert_equal 'GB', loc.country.code

      loc = Locale.set('es-MX')
      assert_equal 'es-MX', loc.language.code
      assert_equal 'MX', loc.country.code
    end
  end

  def test_setting_valid_locale_with_lang_argument_and_country_picking_from_active_locale
    assert_nothing_raised do
      Locale.clear_cache(true)

      loc = nil
      loc = Locale.set('en','US')
      assert_equal 'en', loc.language.code
      assert_equal 'US', loc.country.code

      loc = Locale.set('es')
      assert_equal 'es', loc.language.code
      assert_equal 'US', loc.country.code

      loc = Locale.set('de')
      assert_equal 'de', loc.language.code
      assert_equal 'US', loc.country.code

      loc = Locale.set('sl-Latn-IT-nedis')
      assert_equal 'sl-Latn-IT-nedis', loc.language.code
      assert_equal 'IT', loc.country.code

      loc = Locale.set('es-MX')
      assert_equal 'es-MX', loc.language.code
      assert_equal 'MX', loc.country.code

      loc = Locale.set('de')
      assert_equal 'de', loc.language.code
      assert_equal 'MX', loc.country.code

      loc = Locale.set('de')
      assert_equal 'de', loc.language.code
      assert_equal 'MX', loc.country.code

      loc = Locale.set('zh-Hans')
      assert_equal 'zh-Hans', loc.language.code
      assert_equal 'MX', loc.country.code
    end
  end

  def test_setting_valid_locale_with_lang_argument_and_no_active_locale
    assert_nothing_raised do
      Locale.clear_cache(true)
      Locale.set('es')
    end
  end

  def test_set_nil_locale
    Locale.clear_cache(true)

    assert_nothing_raised do
      Locale.set(nil)
    end
    assert !Locale.active?

    assert_nothing_raised do
      Locale.set(nil,nil)
    end
    assert !Locale.active?

    assert_nothing_raised do
      Locale.set(nil,'US')
    end
    assert !Locale.active?

    Locale.clear_cache(true)

    assert_nothing_raised do
      Locale.set('en-GB')
    end

    assert Locale.active?

    assert_nothing_raised do
      Locale.set(nil)
    end
    assert !Locale.active?
  end

  def test_set_current_locale_with_invalid_tag
    assert_raises(ArgumentError) do
      Locale.set('')
    end

    assert_raises(ArgumentError) do
      Locale.set('i') #invalid rfc_4646
    end

    assert_raises(ArgumentError) do
      Locale.set('zap-Ping') #valid rfc_4646 language tag (Ping not registered)
    end

    assert_raises(ArgumentError) do
      Locale.set('i-navajo') #valid rfc_4646 language tag (grandfathered)
    end

    assert_nothing_raised do
      Locale.set('zap') #valid rfc_4646 language tag
    end

    assert_raises(ArgumentError) do
      Locale.set('en-GB-oed') #invalid rfc_3066 / valid rfc_4646 grandfathered language tag
    end

    assert_raises(ArgumentError) do
      Locale.set('e','US')
    end

    assert_raises(ArgumentError) do
      Locale.set('languages','US')
    end

    assert_raises(ArgumentError) do
      Locale.set('i-aim','US')
    end

    assert_raises(ArgumentError) do
      Locale.set('en-US-Latn','US')
    end

  end

  def test_set_current_locale_with_non_existant_tags
    assert_raises(ArgumentError) do
      Locale.set('no-DE') #non existant valid 'no' language tag
    end

    assert_raises(ArgumentError) do
      Locale.set('en-BA') #non existant valid 'BA' country tag
    end

    assert_raises(ArgumentError) do
      Locale.set('no','DE') #non existant valid 'no' language tag
    end

    assert_raises(ArgumentError) do
      Locale.set('en','BA') #non existant valid 'BA' country tag
    end
  end

  def test_new_locale_with_language_variants
    loc = Locale.new('en-US','US')

    assert_equal 'en-US',        loc.language.code
    assert_equal 'en',           loc.language.primary_subtag
    assert_equal 'English (US)', loc.language.english_name
    assert_equal 'US',           loc.country.code
    assert_equal 'United States', loc.country.english_name
    assert_equal 'en-US',        loc.rfc.tag
    assert_equal 'en',           loc.rfc.primary
    assert_equal 'US',           loc.rfc.region

    loc = Locale.new('es-419','MX')

    assert_equal 'es-419',  loc.language.code
    assert_equal 'es',      loc.language.primary_subtag
    assert_equal 'Spanish (South American)', loc.language.english_name
    assert_equal 'MX',      loc.country.code
    assert_equal 'Mexico',  loc.country.english_name
    assert_equal 'es-419',  loc.rfc.tag
    assert_equal 'es',      loc.rfc.primary
    assert_equal '419',     loc.rfc.region

    loc = Locale.new('es-AR','AR')

    assert_equal 'es-AR',    loc.language.code
    assert_equal 'es',       loc.language.primary_subtag
    assert_equal 'Spanish (Argentina)', loc.language.english_name
    assert_equal 'AR',       loc.country.code
    assert_equal 'Argentina',loc.country.english_name
    assert_equal 'es-AR',    loc.rfc.tag
    assert_equal 'es',       loc.rfc.primary
    assert_equal 'AR',       loc.rfc.region


    loc = Locale.new('zh-Hant','CN')

    assert_equal 'zh-Hant',    loc.language.code
    assert_equal 'zh',         loc.language.primary_subtag
    assert_equal 'traditional Chinese (redundant)', loc.language.english_name
    assert_equal 'CN',       loc.country.code
    assert_equal 'China',    loc.country.english_name
    assert_equal 'zh-Hant',  loc.rfc.tag
    assert_equal 'zh',       loc.rfc.primary
    assert_equal 'Hant',     loc.rfc.script

    loc = Locale.new('zh-Hans','CN')

    assert_equal 'zh-Hans',    loc.language.code
    assert_equal 'zh',         loc.language.primary_subtag
    assert_equal 'simplified Chinese (redundant)', loc.language.english_name
    assert_equal 'CN',       loc.country.code
    assert_equal 'China',    loc.country.english_name
    assert_equal 'zh-Hans',  loc.rfc.tag
    assert_equal 'zh',       loc.rfc.primary
    assert_equal 'Hans',     loc.rfc.script

    loc = Locale.new('zh-Hant-CN','CN')

    assert_equal 'zh-Hant-CN', loc.language.code
    assert_equal 'zh',         loc.language.primary_subtag
    assert_equal 'PRC Mainland Chinese in traditional script (redundant)', loc.language.english_name
    assert_equal 'CN',       loc.country.code
    assert_equal 'China',    loc.country.english_name
    assert_equal 'zh-Hant-CN',  loc.rfc.tag
    assert_equal 'zh',       loc.rfc.primary
    assert_equal 'CN',       loc.rfc.region
    assert_equal 'Hant',     loc.rfc.script

    loc = Locale.new('zh-Hant-TW','TW')

    assert_equal 'zh-Hant-TW', loc.language.code
    assert_equal 'zh',         loc.language.primary_subtag
    assert_equal 'Taiwan Chinese in traditional script (redundant)', loc.language.english_name
    assert_equal 'TW',       loc.country.code
    assert_equal 'Taiwan',   loc.country.english_name
    assert_equal 'zh-Hant-TW',  loc.rfc.tag
    assert_equal 'zh',       loc.rfc.primary
    assert_equal 'TW',       loc.rfc.region
    assert_equal 'Hant',     loc.rfc.script

    loc = Locale.new('zh-guoyu','CN')

    assert_equal 'zh-guoyu', loc.language.code
    assert_equal 'zh',       loc.language.primary_subtag
    assert_equal 'Mandarin or Standard Chinese (grandfathered)', loc.language.english_name
    assert_equal 'CN',       loc.country.code
    assert_equal 'China',    loc.country.english_name
    assert_equal 'zh-guoyu', loc.rfc.tag
    assert_equal 'zh',       loc.rfc.primary
    assert_nil               loc.rfc.script

    loc = Locale.new('zh-cmn','CN')

    assert_equal 'zh-cmn',   loc.language.code
    assert_equal 'zh',       loc.language.primary_subtag
    assert_equal 'Mandarin Chinese (grandfathered)', loc.language.english_name
    assert_equal 'CN',       loc.country.code
    assert_equal 'China',    loc.country.english_name
    assert_equal 'zh-cmn',   loc.rfc.tag
    assert_equal 'zh-cmn',   loc.rfc.primary
    assert_nil               loc.rfc.region
    assert_nil               loc.rfc.script

    loc = Locale.new('zh-cmn-Hant','CN')

    assert_equal 'zh-cmn-Hant', loc.language.code
    assert_equal 'zh',          loc.language.primary_subtag
    assert_equal 'Mandarin Chinese (Traditional) (grandfathered)', loc.language.english_name
    assert_equal 'CN',          loc.country.code
    assert_equal 'China',       loc.country.english_name
    assert_equal 'zh-cmn-Hant', loc.rfc.tag
    assert_equal 'zh-cmn',      loc.rfc.primary
    assert_equal 'Hant',        loc.rfc.script

    loc = Locale.new('zh-cmn-Hans','CN')

    assert_equal 'zh-cmn-Hans', loc.language.code
    assert_equal 'zh',          loc.language.primary_subtag
    assert_equal 'Mandarin Chinese (Simplified) (grandfathered)', loc.language.english_name
    assert_equal 'CN',          loc.country.code
    assert_equal 'China',       loc.country.english_name
    assert_equal 'zh-cmn-Hans', loc.rfc.tag
    assert_equal 'zh-cmn',      loc.rfc.primary
    assert_equal 'Hans',        loc.rfc.script


    loc = Locale.new('zh-yue','CN')

    assert_equal 'zh-yue',   loc.language.code
    assert_equal 'zh',       loc.language.primary_subtag
    assert_equal 'Cantonese (grandfathered)', loc.language.english_name
    assert_equal 'CN',       loc.country.code
    assert_equal 'China',    loc.country.english_name
    assert_equal 'zh-yue',   loc.rfc.tag
    assert_equal 'zh-yue',   loc.rfc.primary
    assert_nil               loc.rfc.script

    loc = Locale.new('en-GB-scouse','GB')

    assert_equal 'en-GB-scouse',   loc.language.code
    assert_equal 'en',             loc.language.primary_subtag
    assert_equal 'English as used in the United Kingdom, Liverpudlian dialect)', loc.language.english_name
    assert_equal 'GB',             loc.country.code
    assert_equal 'United Kingdom', loc.country.english_name
    assert_equal 'en-GB-scouse',   loc.rfc.tag
    assert_equal 'en',             loc.rfc.primary
    assert_equal 'GB',             loc.rfc.region
    assert_includes 'scouse',      loc.rfc.variants

    loc = Locale.set('zap','MX')

    assert_equal 'zap',     loc.language.code
    assert_equal 'Zapotec', loc.language.english_name
    assert_equal 'MX',      loc.country.code
    assert_equal 'Mexico',  loc.country.english_name
    assert_equal 'zap',     loc.rfc.tag
    assert_equal 'zap',     loc.rfc.primary
    assert_nil              loc.rfc.script
    assert_nil              loc.rfc.region

    loc = Locale.new('sl-Latn-IT-nedis','IT')

    assert_equal 'sl-Latn-IT-nedis', loc.language.code
    assert_equal 'sl',               loc.language.primary_subtag
    assert_equal 'Nadiza dialect of Slovenian written using the Latin script as used in Italy', loc.language.english_name
    assert_equal 'IT',               loc.country.code
    assert_equal 'Italy',            loc.country.english_name
    assert_equal 'sl-Latn-IT-nedis', loc.rfc.tag
    assert_equal 'sl',               loc.rfc.primary
    assert_equal 'Latn',             loc.rfc.script
    assert_equal 'IT',               loc.rfc.region
    assert_includes 'nedis',         loc.rfc.variants

    loc = Locale.new('az-Arab-x-AZE-derbend','GB')

    assert_equal 'az-Arab-x-AZE-derbend', loc.language.code
    assert_equal 'az',                    loc.language.primary_subtag
    assert_equal 'Azerbaijani with Arabic script and private use tag', loc.language.english_name
    assert_equal 'GB',               loc.country.code
    assert_equal 'United Kingdom',   loc.country.english_name
    assert_equal 'az-Arab-x-AZE-derbend', loc.rfc.tag
    assert_equal 'az',               loc.rfc.primary
    assert_equal 'Arab',             loc.rfc.script
    assert_nil                       loc.rfc.region
    assert                           loc.rfc.variants.empty?
    assert_equal 'x-AZE-derbend',    loc.rfc.privateuse

  end

  def test_new_locale_with_language_variants_having_region
    loc = Locale.new('en-US')

    assert_equal 'en-US',        loc.language.code
    assert_equal 'en',           loc.language.primary_subtag
    assert_equal 'English (US)', loc.language.english_name
    assert_equal 'US',           loc.country.code
    assert_equal 'United States', loc.country.english_name
    assert_equal 'en-US',        loc.rfc.tag
    assert_equal 'en',           loc.rfc.primary
    assert_equal 'US',           loc.rfc.region

    loc = Locale.new('es-AR')

    assert_equal 'es-AR',    loc.language.code
    assert_equal 'es',       loc.language.primary_subtag
    assert_equal 'Spanish (Argentina)', loc.language.english_name
    assert_equal 'AR',       loc.country.code
    assert_equal 'Argentina',loc.country.english_name
    assert_equal 'es-AR',    loc.rfc.tag
    assert_equal 'es',       loc.rfc.primary
    assert_equal 'AR',       loc.rfc.region

    loc = Locale.new('zh-Hant-CN')

    assert_equal 'zh-Hant-CN', loc.language.code
    assert_equal 'zh',         loc.language.primary_subtag
    assert_equal 'PRC Mainland Chinese in traditional script (redundant)', loc.language.english_name
    assert_equal 'CN',       loc.country.code
    assert_equal 'China',    loc.country.english_name
    assert_equal 'zh-Hant-CN',  loc.rfc.tag
    assert_equal 'zh',       loc.rfc.primary
    assert_equal 'CN',       loc.rfc.region
    assert_equal 'Hant',     loc.rfc.script

    loc = Locale.new('zh-Hant-TW')

    assert_equal 'zh-Hant-TW', loc.language.code
    assert_equal 'zh',         loc.language.primary_subtag
    assert_equal 'Taiwan Chinese in traditional script (redundant)', loc.language.english_name
    assert_equal 'TW',       loc.country.code
    assert_equal 'Taiwan',   loc.country.english_name
    assert_equal 'zh-Hant-TW',  loc.rfc.tag
    assert_equal 'zh',       loc.rfc.primary
    assert_equal 'TW',       loc.rfc.region
    assert_equal 'Hant',     loc.rfc.script

    loc = Locale.new('en-GB-scouse')

    assert_equal 'en-GB-scouse',   loc.language.code
    assert_equal 'en',             loc.language.primary_subtag
    assert_equal 'English as used in the United Kingdom, Liverpudlian dialect)', loc.language.english_name
    assert_equal 'GB',             loc.country.code
    assert_equal 'United Kingdom', loc.country.english_name
    assert_equal 'en-GB-scouse',   loc.rfc.tag
    assert_equal 'en',             loc.rfc.primary
    assert_equal 'GB',             loc.rfc.region
    assert_includes 'scouse',      loc.rfc.variants

    loc = Locale.new('sl-Latn-IT-nedis')

    assert_equal 'sl-Latn-IT-nedis', loc.language.code
    assert_equal 'sl',               loc.language.primary_subtag
    assert_equal 'Nadiza dialect of Slovenian written using the Latin script as used in Italy', loc.language.english_name
    assert_equal 'IT',               loc.country.code
    assert_equal 'Italy',            loc.country.english_name
    assert_equal 'sl-Latn-IT-nedis', loc.rfc.tag
    assert_equal 'sl',               loc.rfc.primary
    assert_equal 'Latn',             loc.rfc.script
    assert_equal 'IT',               loc.rfc.region
    assert_includes 'nedis',         loc.rfc.variants

  end

  def test_implicit_fallbacks
    Locale.clear_cache(true)
    Locale.clear_fallbacks

    Locale.set('en')
    loc_en = Locale.active
    en_fallbacks = ['en-US','en-GB', 'en-GB-scouse', 'en-AU', 'en-NZ']
    assert en_fallbacks.all? {|f| loc_en.fallbacks(false, true).include? f}
    assert !loc_en.fallbacks(false, true).include?('en')

    Locale.set('en-US')
    loc_en_us = Locale.active
    en_us_fallbacks = ['en', 'en-GB', 'en-GB-scouse', 'en-AU', 'en-NZ']
    assert en_us_fallbacks.all? {|f| loc_en_us.fallbacks(false, true).include? f}
    assert !loc_en_us.fallbacks(false, true).include?('en-US')

  end

  def test_explicit_implicit_fallbacks
    Locale.set_fallback('en', 'en-GB', 'en-US')
    Locale.set('en')
    loc_en = Locale.active
    en_explicit_fallbacks = ['en-GB','en-US']
    en_implicit_fallbacks = ['en-GB-scouse', 'en-AU', 'en-NZ']
    en_fallbacks = loc_en.fallbacks(false, true)

    assert_equal en_explicit_fallbacks, en_fallbacks[0..(en_explicit_fallbacks.size - 1)], 'Explicit fallbacks should be first in order'
    assert en_implicit_fallbacks.all? {|f| en_fallbacks[en_explicit_fallbacks.size..(en_fallbacks.size - 1)].include? f}, 'Implicit fallbacks should all be present but in any order'
    assert !en_fallbacks.include?('en')


    Locale.set_fallback('en-US', 'en-GB', 'en-AU', 'en-NZ')
    Locale.set('en-US')
    loc_en_us = Locale.active
    en_us_explicit_fallbacks = ['en-GB', 'en-AU', 'en-NZ', 'en']
    en_us_implicit_fallbacks = ['en-GB-scouse']
    en_us_fallbacks = loc_en_us.fallbacks(false, true)

    assert_equal en_us_explicit_fallbacks, en_us_fallbacks[0..(en_us_explicit_fallbacks.size - 1)], 'Explicit fallbacks should be first in order'
    assert en_us_implicit_fallbacks.all? {|f| en_us_fallbacks[en_us_explicit_fallbacks.size..(en_us_fallbacks.size - 1)].include? f}, 'Implicit fallbacks should all be present but in any order'
    assert !en_us_fallbacks.include?('en-US')
  end

  def test_set_fallbacks
    Locale.clear_cache(true)
    Locale.clear_fallbacks

    es_fallbacks = ['es-AR', 'es-MX']
    en_fallbacks = ['en-GB', 'en-AU']

    assert_nothing_raised do
      assert !(Locale.fallbacks? 'es')
      Locale.set_fallback('es', 'es-AR', 'es-MX')
      assert Locale.fallbacks?('es')
      assert_equal Locale.fallbacks['es'], es_fallbacks
    end

    assert_raises ArgumentError do
      assert !(Locale.fallbacks? 'en')
      Locale.set_fallback('en', 'e1', 'es-MX')
      assert !(Locale.fallbacks? 'en')
    end

    assert_nothing_raised do
      assert_equal Locale.fallbacks['es'], es_fallbacks
      Locale.set_fallback 'es', 'en-GB', 'en-AU'
      assert_not_equal Locale.fallbacks['es'], es_fallbacks
      assert_equal Locale.fallbacks['es'], en_fallbacks
    end

    assert_nothing_raised do
      assert Locale.fallbacks
      assert Locale.fallbacks?('es')
      Locale.clear_fallbacks
      assert Locale.fallbacks.empty?
      assert !Locale.fallbacks?('es')
    end
  end

  def test_switch_locale
    Locale.clear_cache

    loc_es_AR = Locale.new('es','AR')
    loc_es_MX = Locale.new('es','MX')
    loc_en_US = Locale.new('en-US','US')
    loc_es = Locale.set('es','ES')

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_locale('es','AR') do
      assert Locale.active?
      assert_equal loc_es_AR, Locale.active
      assert_equal 'es', Locale.language.code
      assert_equal 'AR', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_locale('es','MX') do
      assert Locale.active?
      assert_equal loc_es_MX, Locale.active
      assert_equal 'es', Locale.language.code
      assert_equal 'MX', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_locale('en-US') do
      assert Locale.active?
      assert_equal loc_en_US, Locale.active
      assert_equal 'en-US', Locale.language.code
      assert_equal 'US', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    assert_nothing_raised do
      Locale.switch_locale(nil,'US') do
        assert Locale.active?
        assert             Locale.active
        assert_equal 'es', Locale.language.code
        assert_equal 'US', Locale.country.code
      end
    end

    assert_raises ArgumentError do
      Locale.switch_locale('e','US') {}
    end

    assert_nothing_raised do
      Locale.switch_locale('es',nil) do
        assert_equal 'es', Locale.language.code
        assert_equal 'ES', Locale.country.code
      end
    end

    assert_raises ArgumentError do
      Locale.switch_locale('e-US') {}
    end

    assert_raises ArgumentError do
      Locale.switch_locale(nil) {}
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_locale('es','MX') do
      assert Locale.active?
      assert_equal loc_es_MX, Locale.active
      assert_equal 'es', Locale.language.code
      assert_equal 'MX', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code
  end

  def test_switch_language
    Locale.clear_cache

    loc_es_AR = Locale.new('es','AR')
    loc_es_MX = Locale.new('es','MX')
    loc_es_US = Locale.new('es','US')
    loc_es = Locale.set('es','ES')

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_language('en') do
      assert Locale.active?
      assert_equal 'en', Locale.language.code
      assert_equal 'ES', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_language('pl') do
      assert Locale.active?
      assert_equal 'pl', Locale.language.code
      assert_equal 'ES', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    assert_nothing_raised do
      Locale.switch_language(nil) {}
    end

    assert_raises ArgumentError do
      Locale.switch_language('e') {}
    end

    assert_raises ArgumentError do
      Locale.switch_language('e-US') {}
    end

    assert_raises ArgumentError do
      Locale.switch_language('') {}
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_language('en') do
      assert Locale.active?
      assert_equal 'en', Locale.language.code
      assert_equal 'ES', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.clear_cache #As we've already defined the 'es_MX' locale

    Locale.switch_language('en') do
      assert Locale.active?
      assert_equal 'en', Locale.language.code
      assert_equal 'ES', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code
  end

  def test_switch_country
    Locale.clear_cache

    loc_es_AR = Locale.new('es','AR')
    loc_es_MX = Locale.new('es','MX')
    loc_es_US = Locale.new('es','US')
    loc_es = Locale.set('es','ES')

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_country('US') do
      assert Locale.active?
      assert_equal 'es', Locale.language.code
      assert_equal 'US', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_country('MX') do
      assert Locale.active?
      assert_equal 'es', Locale.language.code
      assert_equal 'MX', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.switch_country('GB') do
      assert Locale.active?
      assert_equal 'es', Locale.language.code
      assert_equal 'GB', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    assert_raises ArgumentError do
      Locale.switch_country(nil) {}
    end

    assert_raises ArgumentError do
      Locale.switch_country('U') {}
    end

    assert_raises ArgumentError do
      Locale.switch_country('USA') {}
    end

    assert_raises ArgumentError do
      Locale.switch_country('en-US') {}
    end

    assert_raises ArgumentError do
      Locale.switch_country('') {}
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.clear_cache
    Locale.switch_country('MX') do
      assert Locale.active?
      assert_equal 'es', Locale.language.code
      assert_equal 'MX', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code

    Locale.clear_cache
    Locale.switch_country('AR') do
      assert Locale.active?
      assert_equal 'es', Locale.language.code
      assert_equal 'AR', Locale.country.code
    end

    assert Locale.active?
    assert_equal loc_es, Locale.active
    assert_equal 'es', Locale.language.code
    assert_equal 'ES', Locale.country.code
  end

  def test_base_language
    Locale.clear_cache

    loc_en_US = Locale.new('en','US')
    loc_es_AR = Locale.new('es','AR')
    loc_es_MX = Locale.new('es','MX')
    loc_es_US = Locale.new('es','US')
    loc_es = Locale.set('es','ES')

    assert_raises NoBaseLanguageError do
      Locale.base_language
    end

    assert_nothing_raised do
      Locale.set_base_language('es')
      assert_equal loc_es.language, Locale.base_language
    end

    assert_nothing_raised do
      Locale.set_base_language(loc_en_US.language)
      assert_equal loc_en_US.language, Locale.base_language
    end

  end

  def test_possible_codes
    Locale.set_fallback('es', 'es-AR', 'es-MX')
    Locale.set_fallback('en-GB', 'en-US', 'en-AU', 'en-NZ')

    loc = Locale.set('es','ES')

    assert_equal ["es"], Locale.possible_codes('es', false)
    assert_equal ["es", "es-AR", "AR", "es-MX", "MX"], Locale.possible_codes('es', true)

    possible_codes = ["en-GB", "en", "GB"]
    possible_fallbacks = ["en-GB", "en", "GB", "en-US","US", "en-AU", "AU", "en-NZ", "NZ"]

    loc = Locale.set('en-GB')
    assert_equal possible_codes, Locale.possible_codes('en-GB', false)
    assert_equal (possible_codes + possible_fallbacks).uniq, Locale.possible_codes('en-GB', true)
  end

  def test_equality
    language = 'en-US'
    country = 'US'

    loc1 = Locale.new(language, country)
    loc2 = Locale.new(language, country)
    loc3 = Locale.new(language)

    assert loc1 == loc2
    assert loc2 == loc1
    assert loc3 == loc1
    assert loc1 == loc3
    assert loc1.eql?(loc2)
    assert loc2.eql?(loc1)
    assert loc3.eql?(loc1)
    assert loc1.eql?(loc3)

    assert loc1.equal?(loc1)
    assert loc2.equal?(loc2)
    assert loc3.equal?(loc3)

    assert !loc1.equal?(loc2)
    assert !loc2.equal?(loc1)
    assert !loc3.equal?(loc1)
    assert !loc1.equal?(loc3)

  end
end
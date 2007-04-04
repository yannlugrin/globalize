require File.dirname(__FILE__) + '/test_helper'

class LocaleTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages, :globalize_countries

  def setup
  end

  def test_valid_locale_using_rfc_3066
    loc = nil
    assert_stderr_equal "Locale.new(locale) is deprecated! Use Locale.new(language_tag, country_code).\n" do
      loc = Locale.new('en-US')
    end
    assert_equal 'en', loc.language.code
    assert_equal 'US', loc.country.code

    assert_stderr_equal "Locale.set(locale) is deprecated! Use Locale.set(language_tag, country_code).\n" do
      loc = Locale.set('en-US')
    end
    assert_equal 'en', loc.language.code
    assert_equal 'US', loc.country.code
  end

  def test_new_valid_simple_locale
    loc = nil

    assert_stderr_empty do
      loc = Locale.new('en','US')
    end

    assert_equal 'en',      loc.language.code
    assert_equal 'English', loc.language.english_name
    assert_equal 'US',      loc.country.code
    assert_equal 'United States', loc.country.english_name
    assert_equal 'en',      loc.rfc.tag
    assert_equal 'en',      loc.rfc.primary
    assert_nil              loc.rfc.region

    assert_stderr_empty do
      loc = Locale.new('es','ES')
    end

    assert_equal 'es',      loc.language.code
    assert_equal 'Spanish', loc.language.english_name
    assert_equal 'ES',      loc.country.code
    assert_equal 'Spain',   loc.country.english_name
    assert_equal 'es',      loc.rfc.tag
    assert_equal 'es',      loc.rfc.primary
    assert_nil              loc.rfc.region
  end

  def test_set_simple_current_locale
    loc = Locale.set('en','US')

    assert_equal 'en',      loc.language.code
    assert_equal 'English', loc.language.english_name
    assert_equal 'US',      loc.country.code
    assert_equal 'United States', loc.country.english_name
    assert_equal 'en',      loc.rfc.tag
    assert_equal 'en',      loc.rfc.primary
    assert_nil              loc.rfc.region

    loc = Locale.new('es','ES')

    assert_equal 'es',      loc.language.code
    assert_equal 'Spanish', loc.language.english_name
    assert_equal 'ES',      loc.country.code
    assert_equal 'Spain',   loc.country.english_name
    assert_equal 'es',      loc.rfc.tag
    assert_equal 'es',      loc.rfc.primary
    assert_nil              loc.rfc.region
  end

  def test_set_current_locale_with_language_variants
    loc = Locale.set('en-US','US')

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
    assert_nil                       loc.rfc.variants
    assert_equal 'x-AZE-derbend',    loc.rfc.privateuse

  end

end
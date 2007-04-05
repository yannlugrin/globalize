require File.dirname(__FILE__) + '/test_helper'

class LanguageTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages

  def setup
  end

  def test_valid_language_create
    assert_nothing_raised do
      Language.new(:tag => 'sl-Latn-IT',
                       :primary_subtag => 'sl',
                       :english_name => 'Slovenian',
                       :native_name => 'Slovenščina',
                       :direction => 'ltr',
                       :pluralization => 'c == 1 ? 1 : 2')
    end
  end

  def test_invalid_language_create
    lang = nil
    assert_raises ActiveRecord::RecordInvalid do
      lang = Language.new(:primary_subtag => 'en',
                       :english_name => 'English American using the latin script',
                       :native_name => 'English',
                       :direction => 'ltr',
                       :pluralization => 'c == 1 ? 1 : 2')
      lang.save!
    end
    assert lang.errors.on(:tag)

    assert_raises ActiveRecord::RecordInvalid do
      lang = Language.new(:tag => 'en-Latn-US',
                       :english_name => 'English American using the latin script',
                       :native_name => 'English',
                       :direction => 'ltr',
                       :pluralization => 'c == 1 ? 1 : 2')
      lang.save!
    end
    assert lang.errors.on(:primary_subtag)

    assert_raises ActiveRecord::RecordInvalid do
      lang = Language.new(:tag => 'es-Latn-US',
                       :primary_subtag => 'en',
                       :native_name => 'English',
                       :direction => 'ltr',
                       :pluralization => 'c == 1 ? 1 : 2')
      lang.save!
    end
    assert lang.errors.on(:english_name)

    lang = nil
    assert_raises SecurityError do
      lang = Language.new(:tag => 'el-Latn-US',
                       :primary_subtag => 'en',
                       :english_name => 'Greek American using the latin script',
                       :native_name => 'English',
                       :direction => 'ltr',
                       :pluralization => 'ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc')
    end
    assert_nil lang

    lang = nil
    assert_raises SecurityError do
      lang = Language.new(:tag => 'fr-Arab-US',
                       :primary_subtag => 'en',
                       :english_name => 'French American using arabic script',
                       :native_name => 'French',
                       :direction => 'ltr',
                       :pluralization => 'invalid')
      lang.save!
    end
    assert_nil lang
  end

  def test_language_picking
    lang = Language.pick('es')

    assert_equal 'es', lang.tag
    assert_equal 'es', lang.primary_subtag
    assert_equal 'Spanish', lang.english_name
    assert_equal 'Español', lang.native_name

    #Will still work. Uses 'en' tag
    assert_nothing_raised do
      rfc = RFC_3066.parse 'en-US'
      std_err_msg = "Supplying an RFC_3066 instance to Language.pick(rfc_or_tag) is deprecated! Use  a valid rfc_4646 language tag or an instance of RFC_4646).\n"
      assert_stderr_equal std_err_msg do
        lang = Language.pick(rfc)
      end

      assert_equal 'en', lang.tag
      assert_equal 'en', lang.primary_subtag
      assert_equal 'English', lang.english_name
      assert_equal 'English', lang.native_name
    end

    assert_nothing_raised do
      rfc = RFC_4646.parse 'sl-Latn-IT-nedis'
      lang = Language.pick(rfc)
      assert_equal 'sl-Latn-IT-nedis', lang.tag
      assert_equal 'sl', lang.primary_subtag
      assert_equal 'Nadiza dialect of Slovenian written using the Latin script as used in Italy', lang.english_name
      assert_equal 'Slovenščina', lang.native_name
    end

    #Valid rfc-4646 tag intended
    assert_nothing_raised do
      lang = Language.pick('es-AR')
      assert_equal 'es-AR', lang.tag
      assert_equal 'es', lang.primary_subtag
      assert_equal 'Spanish (Argentina)', lang.english_name
      assert_equal 'Español', lang.native_name
    end

    #Intended rfc_3066 valid tag
    #As a rfc_4646 this doesn't exist in the database
    #so we expect an ambiguity exception (TODO: Perhaps should use an ambiguity excpetion class?)
    raised_message = <<-'EOM'
        Language.pick now only accepts a valid rfc_4646 language tag.
        If you supplied a tag with this format {language_code}_{country_code}
        e.g en-US
        it was taken to be the American regional variant of the English language
        and for this reason may not have been found in the database.
        Drop the country code and just use 'en' if you meant to just select the english language.
        If you really did mean to specify es-BL as a valid rfc_4646 tag then this tag
        is NOT available in the database.
        You can add it via:
        EOM

    assert_raises ArgumentError do
      assert_raised_message_equals(raised_message) do
        lang = Language.pick('es-BL')
      end
    end

    raised_message = "Tag 'it' not available in the database. You can add it via:"
    #Intended rfc_4646 valid tag but missing in db
    assert_raises ArgumentError do
      assert_raised_message_equals(raised_message) do
        lang = Language.pick('it')
      end
    end
  end

end

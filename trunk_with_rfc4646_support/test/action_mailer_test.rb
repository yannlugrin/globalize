require File.dirname(__FILE__) + '/test_helper'

class ActionMailerTest < Test::Unit::TestCase
  include Globalize
  fixtures :globalize_languages, :globalize_countries

  class GlobalizeMailer < ActionMailer::Base
    @@subject = "Test"
    @@from = "test@test.com"

    def test
      @charset = 'utf-8'
      recipients      'recipient@test.com'
      subject         @@subject
      from            @@from
      body(:recipient => "recipient")
    end

    alias_method :test_no_multipart, :test
  end

  def setup
    GlobalizeMailer.template_root = File.dirname(__FILE__)
    Locale.set('en','US')
  end

  def test_simple_primary_language
    mail = GlobalizeMailer.create_test
    assert_match "This is the english [en] mail.", mail.to_s

    Locale.set('he','IL')
    mail = GlobalizeMailer.create_test
    assert_match "This is the hebrew [he] mail.", mail.to_s
  end

  def test_exact_language_tag_with_regional_variant_match
    Locale.set('en-US','US')
    mail = GlobalizeMailer.create_test
    assert_match "This is the english [en-US] mail.", mail.to_s
  end

  def test_exact_language_tag_match
    Locale.set('es','ES')
    mail = GlobalizeMailer.create_test
    assert_match "This is the spanish [es] mail.", mail.to_s
  end

  def test_fallback_to_primary_language_for_language_tag_with_regional_variant
    Locale.set('es-MX','ES')
    mail = GlobalizeMailer.create_test
    assert_match "This is the spanish [es] mail.", mail.to_s
  end

  def test_simple_user_defined_fallback_with_exact_language_tag_match
    Locale.set_fallback('de','es')
    Locale.set('de','CH')
    mail = GlobalizeMailer.create_test
    assert_match "This is the spanish [es] mail.", mail.to_s
  end

  def test_fallback_to_primary_language_for_user_defined_fallback_tag_with_regional_variant
    Locale.set_fallback('de','es-MX','en')
    Locale.set('de','CH')
    mail = GlobalizeMailer.create_test
    assert_match "This is the spanish [es] mail.", mail.to_s
  end

  def test_primary_language_matches_before_a_more_specific_second_user_defined_fallback
    Locale.set_fallback('de','en-GB','en-US')
    Locale.set('de','CH')
    mail = GlobalizeMailer.create_test
    assert_match "This is the english [en] mail.", mail.to_s
  end

  def test_matches_specific_user_defined_fallback_before_second_general_fallback
    Locale.set_fallback('de','en-US', 'en-GB')
    Locale.set('de','CH')
    mail = GlobalizeMailer.create_test
    assert_match "This is the english [en-US] mail.", mail.to_s
  end

  def test_nil
    Locale.set(nil)
    mail = GlobalizeMailer.create_test
    assert_match "This is the default mail.", mail.to_s
  end

  def test_fallback_to_primary_language_for_user_defined_fallback_tag_with_regional_variant
    Locale.set_fallback('de','es-MX','en')
    Locale.set('de','CH')
    mail = GlobalizeMailer.create_test_no_multipart
    assert_match "This is the spanish [es] no multipart mail.", mail.to_s
  end


  def test_nil_no_multipart
    Locale.set(nil)
    mail = GlobalizeMailer.create_test_no_multipart
    assert_match "This is the default no multipart mail.", mail.to_s
  end

end
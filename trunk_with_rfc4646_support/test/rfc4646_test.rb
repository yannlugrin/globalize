require File.dirname(__FILE__) + '/test_helper'

class LocaleTest < Test::Unit::TestCase

  include Globalize

  def setup
    @test_files = ['langtagTestWellFormed.txt', 'langtagTestIllFormed.txt']
  end

  def test_well_formed_valid_rfc4646
    File.open(File.join(File.dirname(__FILE__), 'rfc4646', @test_files[0]), 'r') do |f|
      f.readlines.each do |test_string|
        #puts "Matching [well formed]: #{test_string}"
        assert_nothing_thrown do
          RFC_4646.parse(test_string)
        end
      end
    end
  end

  def test_ill_formed_random_rfc4646
    File.open(File.join(File.dirname(__FILE__), 'rfc4646', @test_files[1]), 'r') do |f|
      f.readlines.each do |test_string|
        #puts "Matching [Ill formed]: #{test_string}"
        assert_raises(ArgumentError) do
          RFC_4646.parse(test_string)
        end
      end
    end
  end

  def test_well_formed_full_tag_has_correct_parts
    tag = 'en-Latn-US-lojban-gaulish-a-12345678-ABCD-b-ABCDEFGH-x-a-b-c-12345678'
    rfc = nil

    assert_nothing_thrown do
      rfc = RFC_4646.parse(tag)
    end

    assert_equal tag, rfc.tag
    assert_equal 'en', rfc.primary
    assert_equal 'Latn', rfc.script
    assert_equal 'US', rfc.region
    assert_equal ['lojban','gaulish'], rfc.variants
    assert_equal ['a-12345678-ABCD','b-ABCDEFGH'], rfc.extensions
    assert_equal 'x-a-b-c-12345678', rfc.privateuse
  end

end
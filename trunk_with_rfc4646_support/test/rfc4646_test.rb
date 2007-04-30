require File.dirname(__FILE__) + '/test_helper'
require 'benchmark'

class RFC4646Test < Test::Unit::TestCase

  include Globalize

  def setup
    @test_files = ['langtagTestWellFormed.txt', 'langtagTestIllFormed.txt']
  end

  def test_basic
    rfc = RFC_4646.parse 'en'
    assert_equal 'en', rfc.tag
    assert_equal 'en', rfc.primary
    assert_nil         rfc.script
    assert_nil         rfc.region
    assert             rfc.variants.empty?
    assert             rfc.extensions.empty?
    assert             rfc.extension_match.empty?
    assert_nil         rfc.privateuse
    assert             rfc.irregulars.empty?

    rfc = RFC_4646.parse 'en-US'
    assert_equal 'en-US', rfc.tag
    assert_equal 'en',    rfc.primary
    assert_nil            rfc.script
    assert_equal 'US',    rfc.region
    assert                rfc.variants.empty?
    assert                rfc.extensions.empty?
    assert_nil            rfc.privateuse
    assert                rfc.irregulars.empty?
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

  def test_parsing_well_formed_tags_with_validation
    tag = 'en-Latn-US'
    assert_nothing_thrown do
      rfc = nil
      puts 'Benchmarking non-strict rfc4646 validation...'
      Benchmark.bm do |x|
        x.report { rfc = RFC_4646.parse(tag, false) }
      end

      puts
      Benchmark.bm do |x|
        puts 'Benchmarking strict rfc4646 validation (first-time)...'
        x.report { rfc = RFC_4646.parse(tag, true) }
        puts 'Benchmarking strict rfc4646 validation (second-time)...'
        x.report { rfc = RFC_4646.parse(tag, true) }
      end

      assert_not_nil rfc.lsr
    end
  end

  def test_equality
    tag = 'en-US'
    rfc1 = RFC_4646.parse(tag)
    rfc2 = RFC_4646.parse(tag)

    assert rfc1 == rfc2
    assert rfc2 == rfc1
    assert rfc1.eql?(rfc2)
    assert rfc2.eql?(rfc1)

    assert rfc1.eql?(tag)
    assert rfc2.eql?(tag)

    assert !tag.eql?(rfc1)
    assert !tag.eql?(rfc2)

    assert rfc1.equal?(rfc1)
    assert rfc2.equal?(rfc2)

    assert !rfc1.equal?(rfc2)
    assert !rfc2.equal?(rfc1)

  end

end
require File.dirname(__FILE__) + '/test_helper'

class LanguageSubtagRegistryTest < Test::Unit::TestCase

  include Globalize

  def setup
    @lsr_path = File.join(File.dirname(__FILE__), '../', 'lib','globalize','localization','language-subtag-registry')
  end

  def test_lsr_values
    assert LanguageSubtagRegistry.valid?(@lsr_path)
  end

  def test_lsr_values
    lsr = nil
    assert_nothing_thrown do
      lsr = LanguageSubtagRegistry.parse(@lsr_path)
    end

    assert lsr.tag?('zh-guoyu')
    assert lsr.subtag?('1606nict')
    assert lsr.language?('aa')
    assert lsr.script?('Rjng')
    assert lsr.region?('AM')
    assert lsr.variant?('fonipa')
    assert lsr.redundant?('zh-Hant-SG')
    assert lsr.grandfathered?('zh-guoyu')
    assert lsr.suppress?('ar')

    assert !lsr.tag?('sen-JP')
    assert !lsr.subtag?('012')
    assert !lsr.language?('ac')
    assert !lsr.script?('Pern')
    assert !lsr.region?('016')
    assert !lsr.variant?('valencian')
    assert !lsr.redundant?('art-lojban')
    assert !lsr.suppress?('aa')


    assert_equal 'grandfathered', lsr.entry_for('zh-guoyu')['Type']
    assert_equal 'variant', lsr.entry_for('1606nict')['Type']
    assert_equal 'language', lsr.entry_for('aa')['Type']
    assert_equal 'script', lsr.entry_for('Rjng')['Type']
    assert_equal 'region', lsr.entry_for('AM')['Type']
    assert_equal 'variant', lsr.entry_for('fonipa')['Type']
    assert_equal 'redundant', lsr.entry_for('zh-Hant-SG')['Type']

    assert_equal 'Mandarin or Standard Chinese', lsr.description_for('zh-guoyu')
    assert_equal ['Divehi','Dhivehi','Maldivian'], lsr.description_for('dv')
    assert_equal 'Arab', lsr.suppress('ar')
    assert_equal 'id', lsr.preferred('in')
    assert_equal 'id', lsr.preferred_subtag('in')
    assert_equal 'jbo', lsr.preferred_tag('art-lojban')
  end
end
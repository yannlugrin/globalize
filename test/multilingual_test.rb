# Unit tests for Multilingual Rails.
require File.dirname(__FILE__) + '/test_helper'

MLR_LOCALE_PATH = File.dirname(__FILE__) + '/locales'
MLR_ISO3166_CODE = 'numeric'

class MultilingualController < ActionController::Base
  self.template_root = File.dirname(__FILE__) + '/views/'
  before_filter {|c| Locale.set c.params[:locale]}
  def rescue_action(e); raise e; end
end

class MultilingualModel < ActiveRecord::Base
  validates_length_of :title, :maximum => 5
end


class MultilingualTest < Test::Unit::TestCase
  def setup
    @controller = MultilingualController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    MLR_ISO3166_CODE.replace 'numeric'
    Locale.reload!
  end
  def teardown
    MultilingualModel.connection.drop_table(:multilingual_models) if @created_table
  end


  def test_translated_templates
    get :tpltest, {:locale => 'sv_SE'}
    assert_tag :content => 'tpltest.sv_SE.rhtml'
    get :tpltest, {:locale => 'en_US'}
    assert_tag :content => 'en/tpltest.rhtml'
    get :tpltest, {:locale => 'es_ES'}
    assert_tag :content => 'tpltest.es.rhtml'
    get :tpltest, {:locale => 'de_CH'}
    assert_tag :content => 'tpltest.rhtml'
    get :tpltest, {:locale => 'zh_TW'}
    assert_tag :content => 'zh_TW/tpltest.rhtml'
  end
  
  def test_countries
    Locale.set 'sv_SE'
    assert_equal "Korea, Demokratiska folkrepubliken", Locale.country(408)
    assert_equal "Korea, Nord-", Locale.country(408, :common)
    
    Locale.set 'en_US'
    assert_equal "Korea, Democratic People's Republic of", Locale.country(408, :formal)
    assert_equal "Korea, North", Locale.country(408, :common)

    assert_equal "Elfenbenskusten", Locale.country(384, :common, :sv_SE)
    assert_nil Locale.country(999)
  end
  
  def test_languages
    Locale.set 'sv_SE'
    assert_equal 'Svenska', Locale.language(:sv)
    
    Locale.set 'en_US'
    assert_equal 'Swedish', Locale.language('sv')

    assert_equal 'Norska', Locale.language(:no, :sv_SE)    
    assert_nil Locale.language('xx')
  end
  
  def test_conversions
    assert_equal 'SWE', Locale.iso3166_a2_to_a3(:se)
    assert_equal 752,   Locale.iso3166_a2_to_num('se')
    assert_equal 'SE',  Locale.iso3166_a3_to_a2('swe')
    assert_equal 752,   Locale.iso3166_a3_to_num('SWE')
    assert_equal 'SE',  Locale.iso3166_num_to_a2(752)
    assert_equal 'SWE', Locale.iso3166_num_to_a3(752)
    assert_equal 'SWE', Locale.iso639_1_to_2(:sv)
    assert_equal 'SQ',  Locale.iso639_2_to_1('ALB')
    assert_equal 'SQ',  Locale.iso639_2_to_1(:sQi)
  end
  
  def test_country_select_numeric
    get :select_country, {:locale => 'sv_SE'}
    assert_country    1, :content => 'Sverige',           :attributes => { :value => 752 }
    assert_country    2, :attributes => { :value => 752 }
    assert_no_country 2, :attributes => { :value => 578 }
    assert_country    3, :tag => 'select', :children => { :count => 2, :only => {:attributes => { :value => 752 } } }
    assert_country    4, :tag => 'select', :children => { :count => 11, :only => {:tag => 'option'} }
    assert_country    4, :content => 'Korea, Syd-',       :attributes => { :value => 410 }
    assert_country    5, :content => 'Korea, Republiken', :attributes => { :value => 410 }
    assert_country    6, :content => 'Republiken Korea',  :attributes => { :value => 410 }
    assert_country    7, :content => 'Sydkorea',          :attributes => { :value => 410 }
    
    get :select_country, {:locale => 'en_US'}
    assert_country    7, :content => 'South Korea',       :attributes => { :value => 410 }
  end
  
  def test_country_select_alpha2
    MLR_ISO3166_CODE.replace 'alpha2'
    Locale.reload!
    
    get :select_country, {:locale => 'sv_SE'}
    assert_country    1, :content => 'Sverige', :attributes => { :value => 'SE' }
  end
  
  def test_country_select_alpha3
    MLR_ISO3166_CODE.replace 'alpha3'
    Locale.reload!

    get :select_country, {:locale => 'sv_SE'}
    assert_country    1, :content => 'Sverige', :attributes => { :value => 'SWE' }
  end

  def test_translations_inside_templates
    def assert_title(id,title)
      assert_tag :tag => 'div', :attributes => {:id => "test#{id}"}, :descendant => { :tag => 'h4', :content => title }
    end
    get :select_country, {:locale => 'sv_SE'}
    assert_title 1, "Alla länder"
    
    get :select_country, {:locale => 'en_US'}
    assert_title 1, "All countries"
  end
  
  def test_activerecord_validations
    create_test_table
    m = MultilingualModel.new(:title => 'abcdefghijklm')
    m.valid?
    
    Locale.set 'en_US'
    assert_equal "Title is too long (max is 5 characters)", m.errors.full_messages.first
    
    Locale.set 'sv_SE'
    assert_equal "Titeln är för lång (max 5 tecken)", m.errors.full_messages.first
  end
  
  def test_core_ext
    Locale.set 'sv'
    assert_equal "ett halvår", :half_a_year.t
    assert_equal "för cirka 4 timmar sedan", :time_ago % [:time_about % [:x_hours % [4] ] ]
    assert_equal "foo bar from hell", "foo bar from hell".t
    assert_equal "foo_bar_from_hell", :foo_bar_from_hell.t
    assert_equal "en minut", _(:x_minutes % [1])
  end
  
  def test_pluralization
    Locale.set 'en_US'
    assert_equal "I have no books at home.", :i_have_some_books_at_home % [0]
    assert_equal "I have one book at home.", :i_have_some_books_at_home % [1]
    assert_equal "I have 1234567 books at home.", :i_have_some_books_at_home % [1234567]

    Locale.set 'sv_SE'
    assert_equal "Jag har inga böcker hemma.", :i_have_some_books_at_home % [0]
    assert_equal "Jag har en bok hemma.", :i_have_some_books_at_home % [1]
  end
  
  def test_iconv
    assert_equal "Blåbär", fixture('blueberries.iso-8859-1.txt').iconv_from('iso-8859-1')
    assert_equal "Blåbär", fixture('blueberries.utf-32.txt').iconv_from('utf-32')
    assert_equal "Blåbär".iconv_to('iso-8859-1'), fixture('blueberries.iso-8859-1.txt')
    assert_equal fixture('love.utf-8.txt'), fixture('love.euc-jp.txt').iconv_from('euc-jp')
    assert_equal fixture('love.shift-jis.txt').iconv_from('shift-jis').toeuc, fixture('love.euc-jp.txt')
    string = fixture('love.shift-jis.txt')
    string.iconv_from! 'shift-jis'
    assert_equal string, fixture('love.utf-8.txt')
  end
  
  def test_time
    Locale.set 'sv_SE'
    assert_equal 'Ons-Onsdag-Aug-Augusti', Time.mktime(2005,7,13).strftime('%a-%A-%b-%B')
    Locale.set 'de_DE'
    assert_equal 'Mi-Mittwoch-Aug-August', Time.mktime(2005,7,13).strftime('%a-%A-%b-%B')
  end
    
  
  private
    def create_test_table
      begin
        MultilingualModel.connection.create_table :multilingual_models do |t|
          t.column :title, :string
        end
      rescue
        nil
      ensure
        @created_table = true
      end
    end
    def assert_country(id,test)
      assert_tag :tag => 'div', :attributes => {:id => "test#{id}"}, :descendant => { :tag => 'option' }.merge(test)
    end
    def assert_no_country(id,test)
      assert_no_tag :tag => 'div', :attributes => {:id => "test#{id}"}, :descendant => { :tag => 'option' }.merge(test)
    end
    def fixture(file)
      File.read(File.dirname(__FILE__) + "/fixtures/#{file}")
    end
end

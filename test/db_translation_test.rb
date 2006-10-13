require File.dirname(__FILE__) + '/test_helper'

class TranslationTest < Test::Unit::TestCase
  fixtures :languages, :translations, :products, :manufacturers,
    :categories, :categories_products

  class Product < ActiveRecord::Base
    has_and_belongs_to_many :categories
    belongs_to :manufacturer

    translates :name, :description, :specs
  end

  class Category < ActiveRecord::Base
    has_and_belongs_to_many :products

    translates :name
  end

  class Manufacturer < ActiveRecord::Base
    has_many :products

    translates :name  
  end

  def setup
    Locale.set("en_US")
  end

  def test_native_language
    heb = Language.pick("he")
    assert_equal "עברית", heb.native_name
  end

  def test_prod_tr_all
    prods = Product.find(:all, :order => "code" )
    assert_equal 2, prods.length
    assert_equal "first-product", prods[0].code 
    assert_equal "second-product", prods[1].code 
    assert_equal "these are the specs for the first product",
      prods[0].specs    
    assert_equal "This is a description of the first product",
      prods[0].description    
    assert_equal "these are the specs for the second product",
      prods[1].specs
  end

  def test_prod_tr_first
    prod = Product.find(:first)
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "This is a description of the first product",
      prod.description    
  end

  def test_prod_tr_id
    prod = Product.find(1)
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "This is a description of the first product",
      prod.description    
  end

  def test_prod_tr_ids
    prods = Product.find(1, 2)
    assert_equal 2, prods.length
    assert_equal "first-product", prods[0].code 
    assert_equal "second-product", prods[1].code 
    assert_equal "these are the specs for the first product",
      prods[0].specs    
    assert_equal "This is a description of the first product",
      prods[0].description    
    assert_equal "these are the specs for the second product",
      prods[1].specs
  end

  def test_base
    Locale.set("he_IL")
    prod = Product.find(1)
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description    
  end

  def test_habtm_translation
    Locale.set("he_IL")
    cat = Category.find(1)
    prods = cat.products
    assert_equal 1, prods.length
    prod = prods.first
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description        
  end

  # test has_many translation
  def test_has_many_translation
    Locale.set("he_IL")
    mfr = Manufacturer.find(1)
    prods = mfr.products
    assert_equal 2, prods.length
    prod = prods.first
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description        
  end

  def test_belongs_to_translation
    Locale.set("he_IL")
    prod = Product.find(1)
    mfr = prod.manufacturer
    assert_equal "first-mfr", mfr.code 
    assert_equal "רברנד",
      mfr.name
  end

  def test_new
    prod = Product.new(:code => "new-product", :specs => "These are the product specs")
    assert_equal "These are the product specs", prod.specs
    assert_nil prod.description
  end

  # test creating updating
  def test_create_update
    prod = Product.create(:code => "new-product", 
      :specs => "These are the product specs")
    assert prod.errors.empty?, prod.errors.full_messages.first
    prod = nil
    prod = Product.find_by_code("new-product")
    assert_not_nil prod
    assert_equal "These are the product specs", prod.specs

    prod.specs = "Dummy"
    prod.save
    prod = nil
    prod = Product.find_by_code("new-product")
    assert_not_nil prod
    assert_equal "Dummy", prod.specs
  end

  # association building/creating?
end

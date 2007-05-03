require File.dirname(__FILE__) + '/test_helper'

class TranslationTest < Test::Unit::TestCase
  ::Globalize::DbTranslate.storage_method = :via_association

  self.use_instantiated_fixtures = true
  fixtures :globalize_languages, :globalize_translations, :globalize_countries,
    :globalize_products, :globalize_manufacturers, :globalize_categories,
    :globalize_categories_products, :globalize_simples

  class ::Product < ActiveRecord::Base
    set_table_name "globalize_products"

    has_and_belongs_to_many :categories, :join_table => "globalize_categories_products"
    belongs_to :manufacturer, :foreign_key => 'manufacturer_id'

    translates :name, :description, :specs, {
      :name => { :bidi_embed => false }, :specs => { :bidi_embed => false }}
  end

  class ::Category < ActiveRecord::Base
    set_table_name "globalize_categories"
    has_and_belongs_to_many :products, :join_table => "globalize_categories_products"

    translates :name
  end

  class ::Manufacturer < ActiveRecord::Base
    set_table_name "globalize_manufacturers"
    has_many :products

    translates :name
  end

  class ::Simple < ActiveRecord::Base
    set_table_name "globalize_simples"

    translates :name, :description,
               :name => {:fallback => true},
               :description => {:fallback => false, :base_as_default => false}
  end

  def setup
    ::Globalize::Locale.set_base_language('en')
    ::Globalize::Locale.set('en','US')
  end

  def test_simple
    simp = Simple.find(1)
    assert_equal "first", simp.name
    assert_equal "This is a description of the first simple", simp.description

    ::Globalize::Locale.set('he','IL')
    simp = Simple.find(1)
    assert_equal "זהו השם הראשון", simp.name
    assert_equal "זהו התיאור הראשון", simp.description
  end

  def test_product
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product", prod.specs
    assert_equal "This is a description of the first product", prod.description

    ::Globalize::Locale.set('he','IL')
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description
  end

  def test_simple_save
    simp = Simple.find(1)
    simp.name = '1st'
    simp.save!

    ::Globalize::Locale.set 'he','IL'
    simp = Simple.find(1)
    simp.name = 'ה-1'
    simp.save!
  end

  def test_simple_create
    simp = Simple.new
    simp.name = '1st'
    simp.save!

    ::Globalize::Locale.set 'he','IL'
    simp = Simple.new
    simp.name = 'ה-1'
    simp.save!
  end

  def test_nil
    ::Globalize::Locale.set(nil)
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
  end

  def test_nil_include_translated
    ::Globalize::Locale.set(nil)

    prods = Product.find(:all, :order => "globalize_products.code", :include => :manufacturer)
    assert_equal "first-product", prods[1].code
    assert_equal "these are the specs for the first product",
      prods[1].specs
    assert_equal "first", prods[1].name
    assert_equal "Reverend", prods.first.manufacturer.name
    assert_equal "Reverend", prods.last.manufacturer.name
  end

  def test_prod_tr_all
    prods = Product.find(:all, :order => "code" )
    assert_equal 5, prods.length
    assert_equal "first-product", prods[1].code
    assert_equal "second-product", prods[3].code
    assert_equal "these are the specs for the first product",
      prods[1].specs
    assert_equal "This is a description of the first product",
      prods[1].description
    assert_equal "these are the specs for the second product",
      prods[3].specs
  end

  def test_prod_tr_id
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "This is a description of the first product",
      prod.description
  end

  # Ordering of records returned is database-dependent although MySQL is explicit about ordering
  # its result sets. This means this test is only guaranteed to pass on MySQL.
  def pending_test_prod_tr_ids
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
    ::Globalize::Locale.set('he','IL')
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description
  end

  def test_habtm_translation
    ::Globalize::Locale.set('he','IL')
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
    ::Globalize::Locale.set('he','IL')
    mfr = Manufacturer.find(1)
    assert_equal 5, mfr.products.length
    prod = mfr.products.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description
  end

  def test_belongs_to_translation
    ::Globalize::Locale.set('he','IL')
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

  def test_include
    ::Globalize::Locale.set('he','IL')
    prods = Product.find(:all, :include => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "רברנד", prods.first.manufacturer.name
    assert_equal "רברנד", prods.last.manufacturer.name

    ::Globalize::Locale.set('en','US')
    prods = Product.find(:all, :include => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "Reverend", prods.first.manufacturer.name
    assert_equal "Reverend", prods.last.manufacturer.name
  end

  def test_order_en
    prods = Product.find(:all, :order => "name").select {|rec| rec.name}
    assert_equal 5, prods[0].id
    assert_equal 3, prods[1].id
    assert_equal 4, prods[2].id
  end

  def test_order_he
    ::Globalize::Locale.set('he','IL')
    prods = Product.find(:all, :order => "name").select {|rec| rec.name}
    assert_equal 4, prods[1].id
    assert_equal 5, prods[2].id
    assert_equal 3, prods[3].id
  end

  def test_group_en
    simples = Simple.find(:all, :group => "name")
    assert_equal 2, simples.size
  end

  def test_group_es
    ::Globalize::Locale.set('es','ES')
    simples = Simple.find(:all, :group => "name")
    assert_equal 2, simples.size
  end

  def test_base_translation_create_base_as_default_true
    prod = Product.create!(:code => 'test-base',
                           :name => 'english test',
                           :description => 'english description')
    prod.reload
    assert_equal 'english test', prod.name
    assert_equal 'english description', prod.description

    ::Globalize::Locale.set('he','IL')
    prod = Product.find_by_code('test-base')
    assert_equal 'english test', prod.name                #base_as_default = true
    assert_equal "\xe2\x80\xaaenglish description\xe2\x80\xac", prod.description  #base_as_default = true
    prod.name = "hebrew test"
    prod.description = "hebrew description"
    prod.save!
    prod.reload
    assert_equal 'hebrew test', prod.name
    assert_equal 'hebrew description', prod.description

    # delete hebrew version and test if it reverts to english base
    prod.name = nil
    prod.description = nil
    assert_equal 'english test', prod.name
    assert_equal "\xe2\x80\xaaenglish description\xe2\x80\xac", prod.description
    prod.save!
    prod.reload
    assert_equal 'english test', prod.name
    assert_equal "\xe2\x80\xaaenglish description\xe2\x80\xac", prod.description

    # change base and see if hebrew gets updated
    ::Globalize::Locale.set('en','US')
    prod.reload
    prod.name = "english test two"
    prod.description = "english description two"
    prod.save!
    prod.reload
    assert_equal "english test two", prod.name
    assert_equal "english description two", prod.description
    ::Globalize::Locale.set('he','IL')
    prod.reload
    assert_equal "english test two", prod.name
    assert_equal "\xe2\x80\xaaenglish description two\xe2\x80\xac", prod.description
  end

  def test_base_translation_create_base_as_default_false
    simple = Simple.create!(:name => 'english test',
                          :description => 'english description')
    assert_equal 'english test', simple.name
    assert_equal 'english description', simple.description

    ::Globalize::Locale.set('he','IL')

    assert_equal 'english test', simple.name  #base_as_default = true
    assert_nil simple.description             #base_as_default = false
    simple.name = "hebrew test"
    simple.description = "hebrew description"
    simple.save!
    assert_equal 'hebrew test', simple.name
    assert_equal 'hebrew description', simple.description

    # delete hebrew version and test if it reverts to english base
    simple.name = nil
    simple.description = nil
    assert_equal 'english test', simple.name
    assert_nil simple.description
    simple.save!
    assert_equal 'english test', simple.name
    assert_nil simple.description

    # change base and see if hebrew gets updated
    ::Globalize::Locale.set('en','US')
    simple.name = "english test two"
    simple.description = "english description two"
    simple.save!
    assert_equal "english test two", simple.name
    assert_equal "english description two", simple.description
    ::Globalize::Locale.set('he','IL')
    assert_equal "english test two", simple.name
    assert_nil simple.description
  end

  def test_destroy
    prod = Product.find(1)
    tr = ::Globalize::ModelTranslation.find(:first, :conditions => [
      "item_type = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "Product", 1, "description", 2 ])
    assert_not_nil tr
    prod.destroy
    tr = ::Globalize::ModelTranslation.find(:first, :conditions => [
      "item_type = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "Product", 1, "description", 2 ])
    assert_nil tr
  end

  def test_destroy_class_method
    tr = ::Globalize::ModelTranslation.find(:first, :conditions => [
      "item_type = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "Product", 1, "description", 2 ])
    assert_not_nil tr
    Product.destroy(1)
    tr = ::Globalize::ModelTranslation.find(:first, :conditions => [
      "item_type = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "Product", 1, "description", 2 ])
    assert_nil tr
  end

  def test_returned_base
    ::Globalize::Locale.set('he','IL')
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description

    assert prod.specs_is_base?
    assert !prod.description_is_base?

    assert_equal 'ltr', prod.specs.direction
    assert_equal 'rtl', prod.description.direction
  end

  def test_bidi_embed
    ::Globalize::Locale.set('he','IL')
    prod = Product.find(2)
    assert_equal "\xe2\x80\xaaThis is a description of the second product\xe2\x80\xac",
      prod.description
  end

  def test_fallbacks

    ::Globalize::Locale.set('en','US')
    simp = Simple.new
    simp.name = 'A simple model'
    simp.description = 'A simple model\'s description'
    simp.save!

    ::Globalize::Locale.set('es','ES')
    simp.reload
    simp.name = 'Un modelo simple'
    simp.description = 'La descripción de un modelo simple'
    simp.save!

    ::Globalize::Locale.set('en','US')
    simp.reload
    assert_equal 'A simple model', simp.name
    assert_equal 'A simple model\'s description', simp.description

    ::Globalize::Locale.set('es','ES')
    simp.reload
    assert_equal 'Un modelo simple', simp.name
    assert_equal 'La descripción de un modelo simple', simp.description

    ::Globalize::Locale.set('es-MX','MX')
    simp.reload
    assert_equal 'Un modelo simple', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set('es-MX','MX',[['en','US'],['es','ES']])
    simp.reload
    assert_equal 'A simple model', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set('es-MX','MX',[['es','ES'], ['en','US']])
    simp.reload
    assert_equal 'Un modelo simple', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set('de','CH',[['es','ES'], ['en','US']])
    simp.reload
    assert_equal 'Un modelo simple', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set('de','CH',[['en','US'],['es','ES']])
    simp.reload
    assert_equal 'A simple model', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set('de','CH')
    simp.reload
    assert_equal 'A simple model', simp.name
    assert_nil simp.description
  end

  def test_fallbacks_for_base_locale

    ::Globalize::Locale.set_base_language(Language.pick('es-MX'))

    ::Globalize::Locale.set('he','IL')
    simp = Simple.create!(:name => 'hebrew name fallbacks 2',
                          :description => 'hebrew desc fallbacks 2')
    assert_equal 'hebrew name fallbacks 2', simp.name
    assert_equal 'hebrew desc fallbacks 2', simp.description

    ::Globalize::Locale.set('es-MX','MX')
    simp.reload
    assert_nil simp.name
    assert_nil simp.description

    ::Globalize::Locale.set('es','ES')
    simp.reload
    simp.name = 'spanish name fallbacks 2'
    simp.description = 'spanish desc fallbacks 2'
    simp.save!
    assert_equal 'spanish name fallbacks 2', simp.name
    assert_equal 'spanish desc fallbacks 2', simp.description

    ::Globalize::Locale.set('es-MX','MX')
    simp.reload
    assert_equal 'spanish name fallbacks 2', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set('es-MX','ES', [['he','IL']])
    simp.reload
    assert_equal 'hebrew name fallbacks 2', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set_base_language(Language.pick('en'))
  end

  def test_dynamic_finders
    prod1 = Product.find_by_name('efe')
    prod2 = Product.find_by_name('ear')
    assert_not_nil prod1
    assert_not_nil prod2

    ::Globalize::Locale.set('he_IL')
    prod3 = Product.find_by_name('סקר')
    assert_not_nil prod3
    assert_equal prod1, prod3

    ::Globalize::Locale.set('es_ES')
    prod4 = Product.find_by_name_and_description('oreja','descripción de oreja')
    assert_not_nil prod4
    assert_equal prod2, prod4

    prod4 = Product.find_or_create_by_name('oreja')
    assert_not_nil prod4
    assert_equal prod2, prod4
  end
end
require File.dirname(__FILE__) + '/test_helper'

class ViaAssociationTranslationTest < Test::Unit::TestCase

  self.use_instantiated_fixtures = true
  fixtures :globalize_languages, :globalize_translations, :globalize_countries,
    :globalize_items, :globalize_orders, :globalize_options,
    :globalize_options_items, :globalize_simples

  class ::Item < ActiveRecord::Base
    set_table_name "globalize_items"

    has_and_belongs_to_many :options, :join_table => "globalize_options_items"
    belongs_to :order

    self.globalize_translation_storage_method = :via_association
    translates :name, :description, :specs, {
      :name => { :bidi_embed => false }, :specs => { :bidi_embed => false }}
  end

  class ::Option < ActiveRecord::Base
    set_table_name "globalize_options"
    has_and_belongs_to_many :items, :join_table => "globalize_options_items"

    self.globalize_translation_storage_method = :via_association
    translates :name
  end

  class ::Order < ActiveRecord::Base
    set_table_name "globalize_orders"
    has_many :items

    self.globalize_translation_storage_method = :via_association
    translates :name
  end

  class ::SimplePost < ActiveRecord::Base
    set_table_name "globalize_simples"

    self.globalize_translation_storage_method = :via_association
    translates :name, :description,
               :name => {:fallback => true},
               :description => {:fallback => false, :base_as_default => false}
  end

  def setup
    ::Globalize::Locale.set_base_language('en')
    ::Globalize::Locale.set('en','US')
  end

  def test_simple
    simp = SimplePost.find(1)
    assert_equal "first", simp.name
    assert_equal "This is a description of the first simple", simp.description

    ::Globalize::Locale.set('he','IL')
    simp = SimplePost.find(1)
    assert_equal "זהו השם הראשון", simp.name
    assert_equal "זהו התיאור הראשון", simp.description
  end

  def test_product
    item = Item.find(1)
    assert_equal "first-product", item.code
    assert_equal "these are the specs for the first product", item.specs
    assert_equal "This is a description of the first product", item.description

    ::Globalize::Locale.set('he','IL')
    item = Item.find(1)
    assert_equal "first-product", item.code
    assert_equal "these are the specs for the first product",
      item.specs
    assert_equal "זהו תיאור המוצר הראשון",
      item.description
  end

  def test_simple_save
    simp = SimplePost.find(1)
    simp.name = '1st'
    simp.save!

    ::Globalize::Locale.set 'he','IL'
    simp = SimplePost.find(1)
    simp.name = 'ה-1'
    simp.save!
  end

  def test_simple_create
    simp = SimplePost.new
    simp.name = '1st'
    simp.save!

    ::Globalize::Locale.set 'he','IL'
    simp = SimplePost.new
    simp.name = 'ה-1'
    simp.save!
  end

  def test_nil
    ::Globalize::Locale.set(nil)
    item = Item.find(1)
    assert_equal "first-product", item.code
    assert_equal "these are the specs for the first product",
      item.specs
  end

  def test_nil_include_translated
    ::Globalize::Locale.set(nil)

    items = Item.find(:all, :order => "globalize_items.code", :include => :order)
    assert_equal "first-product", items[1].code
    assert_equal "these are the specs for the first product",
      items[1].specs
    assert_equal "first", items[1].name
    assert_equal "Reverend", items.first.order.name
    assert_equal "Reverend", items.last.order.name
  end

  def test_prod_tr_all
    items = Item.find(:all, :order => "code" )
    assert_equal 5, items.length
    assert_equal "first-product", items[1].code
    assert_equal "second-product", items[3].code
    assert_equal "these are the specs for the first product",
      items[1].specs
    assert_equal "This is a description of the first product",
      items[1].description
    assert_equal "these are the specs for the second product",
      items[3].specs
  end

  def test_prod_tr_id
    item = Item.find(1)
    assert_equal "first-product", item.code
    assert_equal "these are the specs for the first product",
      item.specs
    assert_equal "This is a description of the first product",
      item.description
  end

  # Ordering of records returned is database-dependent although MySQL is explicit about ordering
  # its result sets. This means this test is only guaranteed to pass on MySQL.
  def pending_test_prod_tr_ids
    items = Item.find(1, 2)
    assert_equal 2, items.length
    assert_equal "first-product", items[0].code
    assert_equal "second-product", items[1].code
    assert_equal "these are the specs for the first product",
      items[0].specs
    assert_equal "This is a description of the first product",
      items[0].description
    assert_equal "these are the specs for the second product",
      items[1].specs
  end

  def test_base
    ::Globalize::Locale.set('he','IL')
    item = Item.find(1)
    assert_equal "first-product", item.code
    assert_equal "these are the specs for the first product",
      item.specs
    assert_equal "זהו תיאור המוצר הראשון",
      item.description
  end

  def test_habtm_translation
    ::Globalize::Locale.set('he','IL')
    option = Option.find(1)
    items = option.items
    assert_equal 1, items.length
    item = items.first
    assert_equal "first-product", item.code
    assert_equal "these are the specs for the first product",
      item.specs
    assert_equal "זהו תיאור המוצר הראשון",
      item.description
  end

  # test has_many translation
  def test_has_many_translation
    ::Globalize::Locale.set('he','IL')
    order = Order.find(1)
    assert_equal 5, order.items.length
    item = order.items.find(1)
    assert_equal "first-product", item.code
    assert_equal "these are the specs for the first product",
      item.specs
    assert_equal "זהו תיאור המוצר הראשון",
      item.description
  end

  def test_belongs_to_translation
    ::Globalize::Locale.set('he','IL')
    item = Item.find(1)
    order = item.order
    assert_equal "first-mfr", order.code
    assert_equal "רברנד",
      order.name
  end

  def test_new
    item = Item.new(:code => "new-product", :specs => "These are the product specs")
    assert_equal "These are the product specs", item.specs
    assert_nil item.description
  end

  # test creating updating
  def test_create_update
    item = Item.create(:code => "new-product",
      :specs => "These are the product specs")
    assert item.errors.empty?, item.errors.full_messages.first
    item = nil
    item = Item.find_by_code("new-product")
    assert_not_nil item
    assert_equal "These are the product specs", item.specs

    item.specs = "Dummy"
    item.save
    item = nil
    item = Item.find_by_code("new-product")
    assert_not_nil item
    assert_equal "Dummy", item.specs
  end

  def test_include
    ::Globalize::Locale.set('he','IL')
    items = Item.find(:all, :include => :order)
    assert_equal 5, items.size
    assert_equal "רברנד", items.first.order.name
    assert_equal "רברנד", items.last.order.name

    ::Globalize::Locale.set('en','US')
    items = Item.find(:all, :include => :order)
    assert_equal 5, items.size
    assert_equal "Reverend", items.first.order.name
    assert_equal "Reverend", items.last.order.name
  end

  def test_order_en
    items = Item.find(:all, :order => "name").select {|rec| rec.name}
    assert_equal 5, items[0].id
    assert_equal 3, items[1].id
    assert_equal 4, items[2].id
  end

  def test_order_he
    ::Globalize::Locale.set('he','IL')
    items = Item.find(:all, :order => "name").select {|rec| rec.name}
    assert_equal 4, items[1].id
    assert_equal 5, items[2].id
    assert_equal 3, items[3].id
  end

  def test_group_en
    simples = SimplePost.find(:all, :group => "name")
    assert_equal 2, simples.size
  end

  def test_group_es
    ::Globalize::Locale.set('es','ES')
    simples = SimplePost.find(:all, :group => "name")
    assert_equal 2, simples.size
  end

  def test_base_translation_create_base_as_default_true
    item = Item.create!(:code => 'test-base',
                           :name => 'english test',
                           :description => 'english description')
    item.reload
    assert_equal 'english test', item.name
    assert_equal 'english description', item.description

    ::Globalize::Locale.set('he','IL')
    item = Item.find_by_code('test-base')
    assert_equal 'english test', item.name                #base_as_default = true
    assert_equal "\xe2\x80\xaaenglish description\xe2\x80\xac", item.description  #base_as_default = true
    item.name = "hebrew test"
    item.description = "hebrew description"
    item.save!
    item.reload
    assert_equal 'hebrew test', item.name
    assert_equal 'hebrew description', item.description

    # delete hebrew version and test if it reverts to english base
    item.name = nil
    item.description = nil
    assert_equal 'english test', item.name
    assert_equal "\xe2\x80\xaaenglish description\xe2\x80\xac", item.description
    item.save!
    item.reload
    assert_equal 'english test', item.name
    assert_equal "\xe2\x80\xaaenglish description\xe2\x80\xac", item.description

    # change base and see if hebrew gets updated
    ::Globalize::Locale.set('en','US')
    item.reload
    item.name = "english test two"
    item.description = "english description two"
    item.save!
    item.reload
    assert_equal "english test two", item.name
    assert_equal "english description two", item.description
    ::Globalize::Locale.set('he','IL')
    item.reload
    assert_equal "english test two", item.name
    assert_equal "\xe2\x80\xaaenglish description two\xe2\x80\xac", item.description
  end

  def test_base_translation_create_base_as_default_false
    simple = SimplePost.create!(:name => 'english test',
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
    item = Item.find(1)
    tr = ::Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_not_nil tr
    item.destroy
    tr = ::Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_nil tr
  end

  def test_destroy_class_method
    tr = ::Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_not_nil tr
    Item.destroy(1)
    tr = ::Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_nil tr
  end

  def test_returned_base
    ::Globalize::Locale.set('he','IL')
    item = Item.find(1)
    assert_equal "first-product", item.code
    assert_equal "these are the specs for the first product",
      item.specs
    assert_equal "זהו תיאור המוצר הראשון",
      item.description

    assert item.specs_is_base?
    assert !item.description_is_base?

    assert_equal 'ltr', item.specs.direction
    assert_equal 'rtl', item.description.direction
  end

  def test_bidi_embed
    ::Globalize::Locale.set('he','IL')
    item = Item.find(2)
    assert_equal "\xe2\x80\xaaThis is a description of the second product\xe2\x80\xac",
      item.description
  end

  def test_fallbacks

    ::Globalize::Locale.set('en','US')
    simp = SimplePost.new
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

    ::Globalize::Locale.set_fallback('es-MX', 'en', 'es')
    ::Globalize::Locale.set('es-MX')
    simp.reload
    assert_equal 'A simple model', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set_fallback('es-MX', 'es', 'en')
    ::Globalize::Locale.set('es-MX')
    simp.reload
    assert_equal 'Un modelo simple', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set_fallback('de', 'es', 'en')
    ::Globalize::Locale.set('de')
    simp.reload
    assert_equal 'Un modelo simple', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set_fallback('de', 'en', 'es')
    ::Globalize::Locale.set('de')
    simp.reload
    assert_equal 'A simple model', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set('de','CH')
    simp.reload
    assert_equal 'A simple model', simp.name
    assert_nil simp.description
  end

  def test_fallbacks_for_base_locale

    ::Globalize::Locale.clear_fallbacks
    ::Globalize::Locale.set_base_language(Language.pick('es-MX'))

    ::Globalize::Locale.set('he','IL')
    simp = SimplePost.create!(:name => 'hebrew name fallbacks 2',
                          :description => 'hebrew desc fallbacks 2')
    assert_equal 'hebrew name fallbacks 2', simp.name
    assert_equal 'hebrew desc fallbacks 2', simp.description

    ::Globalize::Locale.set('es-MX')
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

    ::Globalize::Locale.set('es-MX')
    simp.reload
    assert_equal 'spanish name fallbacks 2', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set_fallback('es-MX', 'he')
    ::Globalize::Locale.set('es-MX')
    simp.reload
    assert_equal 'hebrew name fallbacks 2', simp.name
    assert_nil simp.description

    ::Globalize::Locale.set_base_language(Language.pick('en'))
  end

  def test_dynamic_finders
    item1 = Item.find_by_name('efe')
    item2 = Item.find_by_name('ear')
    assert_not_nil item1
    assert_not_nil item2

    ::Globalize::Locale.set('he','IL')
    item3 = Item.find_by_name('סקר')
    assert_not_nil item3
    assert_equal item1, item3

    ::Globalize::Locale.set('es','ES')
    item4 = Item.find_by_name_and_description('oreja','descripción de oreja')
    assert_not_nil item4
    assert_equal item2, item4

    item4 = Item.find_or_create_by_name('oreja')
    assert_not_nil item4
    assert_equal item2, item4
  end
end
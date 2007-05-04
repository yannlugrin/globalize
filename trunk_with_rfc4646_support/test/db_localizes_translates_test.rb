require File.dirname(__FILE__) + '/test_helper'

class LocalizesTranslatesTest < Test::Unit::TestCase

  self.use_instantiated_fixtures = true
  fixtures :globalize_languages, :globalize_translations, :globalize_countries,
    :globalize_articles, :globalize_authors, :globalize_tags,
    :globalize_tags_articles, :globalize_simples, :globalize_unlocalized_classes

  class ::Article < ActiveRecord::Base
    set_table_name "globalize_articles"

    has_and_belongs_to_many :tags, :join_table => "globalize_tags_articles"
    belongs_to :author

    self.globalize_translation_storage_method = :same_table
    translates :name, :description, :specs,
               :name => {:fallback => true},
               :description => {:fallback => false, :base_as_default => false}
  end

  class ::Tag < ActiveRecord::Base
    set_table_name "globalize_tags"
    has_and_belongs_to_many :articles,
       :join_table => "globalize_tags_articles"

    self.globalize_translation_storage_method = :same_table
    translates :name
  end

  class ::Author < ActiveRecord::Base
    set_table_name "globalize_authors"
    has_many :articles

    self.globalize_translation_storage_method = :same_table
    translates :name
  end

  class ::SimpleArticle < ActiveRecord::Base
    set_table_name "globalize_simples"

    self.globalize_translation_storage_method = :same_table
    translates :name, :description
  end

  class ::UnlocalizedClass < ActiveRecord::Base
    set_table_name "globalize_unlocalized_classes"
  end

  def setup
    ::Globalize::Locale.set_base_language(Language.pick('en'))
    ::Globalize::Locale.set('en','US')
  end

  def test_access_base_locale_column
    simp = ::SimpleArticle.find(1)
    simp.name = 'First'
    simp.save!
    assert_equal simp.name, simp._name

    ::Globalize::Locale.set 'es','ES'
    simp.name = 'Primer'
    simp.save!
    assert_equal "First", simp._name
    assert_equal "Primer", simp.name

    simp._name = 'Second'
    simp.save!

    assert_equal "Primer", simp.name
    assert_equal "Second", simp._name

    ::Globalize::Locale.set 'en','US'
    assert_equal simp.name, simp._name
  end

  def test_find_by_override
    ::Globalize::Locale.set('en','US')
    first_article  = ::Article.find_by_name('first')
    fourth_article = ::Article.find_by_name('eff')
    second_article = ::Article.find_by_description('This is a description of the second product')
    assert_equal second_article, ::Article.find_by_specs('these are the specs for the second product')


    ::Globalize::Locale.set('es','ES')
    assert_equal first_article, ::Article.find_by_name('primer')
    assert_equal fourth_article, ::Article.find_by_name('effes')
    assert_equal second_article, ::Article.find_by_description('Esta es una descripcion del segundo producto')
    assert_equal second_article, ::Article.find_by_specs('estas son las especificaciones del segundo producto')

    ::Globalize::Locale.set('he','IL')
    assert_equal fourth_article, ::Article.find_by_name('סארט')
    assert_equal fourth_article, ::Article.find_or_create_by_name('סארט')
  end

  def test_base_as_default_false
    article = ::Article.create!(:code => 'test-base', :description => 'english test')
    assert_equal 'english test', article.description

    ::Globalize::Locale.set('es','ES')
    assert_nil article.description
    assert_nil article.description_before_type_cast

    article.description = "spanish test"
    article.save!

    assert_equal 'spanish test', article.description
    assert_equal 'spanish test', article.description_before_type_cast

    # delete spanish version and test if it reverts to english base
    article.description = nil
    article.save!

    assert_nil article.description
    assert_nil article.description_before_type_cast

    assert !article.translated?(:name)
    assert article.description_is_base?

    article.save!
    assert_nil article.description

    #test access of base column
    assert_equal 'english test', article._description
    assert_equal 'english test', article._description_before_type_cast

    # change base and see if spanish gets updated
    ::Globalize::Locale.set('en','US')
    article.description = "english test two"
    article.save!
    assert_equal "english test two", article.description
    assert_equal "english test two", article.description_before_type_cast
    ::Globalize::Locale.set('es','ES')
    assert_nil article.description
    assert_nil article.description_before_type_cast
  end

  def test_base_as_default_true

    article = ::Article.create!(:code => 'test-base', :name => 'english test')
    assert_equal 'english test', article.name
    assert_equal 'english test', article.name_before_type_cast
    ::Globalize::Locale.set('es','ES')
    assert_equal 'english test', article.name
    assert_equal 'english test', article.name_before_type_cast
    article.name = "spanish test"
    article.save!
    assert_equal 'spanish test', article.name
    assert_equal 'spanish test', article.name_before_type_cast

    # delete spanish version and test if it reverts to english base
    article.name = nil
    assert_equal 'english test', article.name
    assert_equal 'english test', article.name_before_type_cast
    article.save!
    assert_equal 'english test', article.name
    assert_equal 'english test', article.name_before_type_cast

    #test access of base column
    assert_equal 'english test', article._name
    assert_equal 'english test', article._name_before_type_cast

    # change base and see if spanish gets updated
    ::Globalize::Locale.set('en','US')
    article.name = "english test two"
    article.save!
    assert_equal "english test two", article.name
    assert_equal "english test two", article.name_before_type_cast
    ::Globalize::Locale.set('es','ES')
    assert_equal "english test two", article.name
    assert_equal "english test two", article.name_before_type_cast
  end

  def test_find_by_on_unlocalized_class
    seymour = ::UnlocalizedClass.find_by_name('Seymour')
    assert_equal 'Seymour', seymour.name

    ::Globalize::Locale.set 'es','ES'
    wellington = ::UnlocalizedClass.find_by_code('cat1')
    assert_equal 'Wellington', wellington.name
  end

  def test_simple
    simp = ::SimpleArticle.find(1)
    assert_equal "first", simp.name
    assert_equal "This is a description of the first simple", simp.description

    ::Globalize::Locale.set 'es','ES'
    assert_equal "primer", simp.name
    assert_equal "Esta es una descripcion del primer simple", simp.description
  end

  def test_simple_save
    simp = ::SimpleArticle.find(1)
    simp.name = '1st'
    simp.save!

    ::Globalize::Locale.set 'es','ES'
    simp.name = '1º'
    simp.save!
  end

  def test_simple_create
    simp = ::SimpleArticle.new
    simp.name = '1st'
    simp.save!

    ::Globalize::Locale.set 'es','ES'
    simp = ::SimpleArticle.new
    simp.name = '1º'
    simp.save!
  end

  def test_native_language
    es = ::Globalize::Language.pick("es")
    assert_equal "Español", es.native_name
  end

  def test_nil
    ::Globalize::Locale.set(nil)
    article = ::Article.find(1)
    assert_equal "first-product", article.code
    assert_equal "these are the specs for the first product", article.specs
  end

  def test_prod_tr_all
    articles = ::Article.find(:all, :order => "code" )
    assert_equal 5, articles.length
    assert_equal "first-product", articles[1].code
    assert_equal "second-product", articles[3].code
    assert_equal "these are the specs for the first product",
      articles[1].specs
    assert_equal "This is a description of the first product",
      articles[1].description
    assert_equal "these are the specs for the second product",
      articles[3].specs
  end

  def test_prod_tr_first
    article = ::Article.find(1)
    assert_equal "first-product", article.code
    assert_equal "these are the specs for the first product",
      article.specs
    assert_equal "This is a description of the first product",
      article.description
  end

  def test_prod_tr_id
    article = ::Article.find(1)
    assert_equal "first-product", article.code
    assert_equal "these are the specs for the first product",
      article.specs
    assert_equal "This is a description of the first product",
      article.description
  end

  # Ordering of records returned is database-dependent although MySQL is explicit about ordering
  # its result sets. This means this test is only guaranteed to pass on MySQL.
  def pending_test_prod_tr_ids
    articles = ::Article.find(1, 2)
    assert_equal 2, articles.length
    assert_equal "first-product", articles[0].code
    assert_equal "second-product", articles[1].code
    assert_equal "these are the specs for the first product",
      articles[0].specs
    assert_equal "This is a description of the first product",
      articles[0].description
    assert_equal "these are the specs for the second product",
      articles[1].specs
  end

  def test_base
    ::Globalize::Locale.set('es','ES')
    article = ::Article.find(1)
    assert_equal "first-product", article.code
    assert_equal "estas son las especificaciones del primer producto",
      article.specs
    assert_equal "Esta es una descripcion del primer producto",
      article.description
  end

  def test_habtm_translation
    ::Globalize::Locale.set('es','ES')
    tag = Tag.find(1)
    articles = tag.articles
    assert_equal 1, articles.length
    article = articles.first
    assert_equal "first-product", article.code
    assert_equal "estas son las especificaciones del primer producto",
      article.specs
    assert_equal "Esta es una descripcion del primer producto",
      article.description
  end

  # test has_many translation
  def test_has_many_translation
    ::Globalize::Locale.set('es','ES')
    author= ::Author.find(1)
    assert_equal 5, author.articles.length
    article = author.articles.find(1)
    assert_equal "first-product", article.code
    assert_equal "estas son las especificaciones del primer producto",
      article.specs
    assert_equal "Esta es una descripcion del primer producto",
      article.description
  end

  def test_belongs_to_translation
    ::Globalize::Locale.set('es','ES')
    article = ::Article.find(1)
    author= article.author
    assert_equal "first-mfr", author.code
    assert_equal "Reverendo",
      author.name
  end

  def test_new
    article = ::Article.new(:code => "new-product", :specs => "These are the product specs")
    assert_equal "These are the product specs", article.specs
    assert_nil article.description
  end

  # test creating updating
  def test_create_update
    article = ::Article.create(:code => "new-product",
      :specs => "These are the product specs")
    assert article.errors.empty?, article.errors.full_messages.first
    article = nil
    article = ::Article.find_by_code("new-product")
    assert_not_nil article
    assert_equal "These are the product specs", article.specs

    article.specs = "Dummy"
    article.save
    article = nil
    article = ::Article.find_by_code("new-product")
    assert_not_nil article
    assert_equal "Dummy", article.specs
  end

  def test_include
    ::Globalize::Locale.set('es','ES')
    articles = ::Article.find(:all, :include => :author)
    assert_equal 5, articles.size
    assert_equal "first-mfr", articles.first.author.code
    assert_equal "Reverendo", articles.first.author.name
    assert_equal "Reverendo", articles.last.author.name

    ::Globalize::Locale.set('en','US')
    articles = ::Article.find(:all, :include => :author)
    assert_equal 5, articles.size
    assert_equal "first-mfr", articles.first.author.code
    assert_equal "Reverend", articles.first.author.name
    assert_equal "Reverend", articles.last.author.name
  end

  def test_order_en
    articles = ::Article.find(:all, :order => ::Article.localized_facet(:name)).select {|rec| rec.name}
    assert_equal 5, articles[0].id
    assert_equal 3, articles[1].id
    assert_equal 4, articles[2].id
  end

  def test_order_es
    ::Globalize::Locale.set('es','ES')
    articles = ::Article.find(:all, :order => ::Article.localized_facet(:name)).select {|rec| rec.name}
    assert_equal 3, articles[0].id
    assert_equal 4, articles[1].id
    assert_equal 5, articles[2].id
  end

  def test_base_translation_create
    article = ::Article.create!(:code => 'test-base', :name => 'english test')
    article.reload
    assert_equal 'english test', article.name
    ::Globalize::Locale.set('es','ES')
    assert_equal 'english test', article.name
    article.name = "spanish test"
    article.save!
    article.reload
    assert_equal 'spanish test', article.name

    # delete spanish version and test if it reverts to english base
    article.name = nil
    assert_equal 'english test', article.name
    article.save!
    article.reload
    assert_equal 'english test', article.name
    assert_equal 'english test', article._name

    # change base and see if spanish gets updated
    ::Globalize::Locale.set('en','US')
    article.reload
    article.name = "english test two"
    article.save!
    article.reload
    assert_equal "english test two", article.name
    ::Globalize::Locale.set('es','ES')
    article.reload
    assert_equal "english test two", article.name
  end

  def test_native_name
    heb = ::Globalize::Language.pick('he')
    assert_equal 'Hebrew', heb.english_name
    assert_equal 'עברית', heb.native_name
    urdu = ::Globalize::Language.pick('ur')
    assert_equal 'Urdu', urdu.english_name
    assert_equal 'Urdu', urdu.native_name
  end

  def test_association_create
    author = ::Author.find(:first)
    author.articles.create(:code => 'a-code',
                                 :name => 'english name',
                                 :description => 'english description',
                                 :specs => 'english specs')


    article = author.articles.find(:first, :conditions => ["#{::Article.localized_facet(:name)} = ?", 'english name'])

    assert_equal 'english name', article.name
    assert_equal 'english description', article.description
    assert_equal 'english specs', article.specs

    ::Globalize::Locale.set('es','ES')

    assert_equal 'english name', article.name
    assert_nil article.description
    assert_equal 'english specs', article.specs

    assert_equal 'english name', article._name
    assert_equal 'english description', article._description
    assert_equal 'english specs', article._specs

    article.name        = 'nombre castellano'
    article.description = 'descripcion castellana'
    article.specs       = 'especificaciones castellanas'
    article.save!

    article = author.articles.find(:first, :conditions => ["#{::Article.localized_facet(:name)} = ?", 'nombre castellano'])

    assert_equal 'nombre castellano',            article.name
    assert_equal 'descripcion castellana'      , article.description
    assert_equal 'especificaciones castellanas', article.specs

    assert_equal 'english name',                 article._name
    assert_equal 'english description',          article._description
    assert_equal 'english specs',                article._specs

    assert  article.translated?(:name)
    assert  article.translated?(:description)
    assert  article.translated?(:specs)

    ::Globalize::Locale.set('en','US')
    assert_equal 'english name',                 article.name
    assert_equal 'english description',          article.description
    assert_equal 'english specs',                article.specs

    assert  article.translated?(:name, 'es')
    assert  article.translated?(:description, 'es')
    assert  article.translated?(:specs, 'es')
  end

  def test_returned_base

    ::Article.class_eval %{
      self.globalize_translation_storage_method = :same_table
      translates :name, :description, :specs, {
        :base_as_default => true,
        :name => { :bidi_embed => false }, :specs => { :bidi_embed => false }
      }
    }

    ::Globalize::Locale.set('he','IL')
    article = ::Article.find(1)
    assert_equal "first-product", article.code
    assert_equal "these are the specs for the first product", article.specs
    assert_equal "זהו תיאור המוצר הראשון", article.description

    assert article.specs_is_base?
    assert !article.description_is_base?

    assert_equal 'ltr', article.specs.direction
    assert_equal 'rtl', article.description.direction

    ::Article.class_eval %{
      self.globalize_translation_storage_method = :same_table
      translates :name, :description, :specs,
           :name => {:fallback => true},
           :description => {:fallback => false, :base_as_default => false}
    }
  end

  def test_bidi_embed
    ::Article.class_eval %{
      self.globalize_translation_storage_method = :same_table
      translates :name, :description, :specs, {
        :base_as_default => true,
        :name => { :bidi_embed => false }, :specs => { :bidi_embed => false }
      }
    }

    ::Globalize::Locale.set('he','IL')
    article = ::Article.find(2)
    assert_equal "\xe2\x80\xaaThis is a description of the second product\xe2\x80\xac",
      article.description

    ::Article.class_eval %{
      self.globalize_translation_storage_method = :same_table
      translates :name, :description, :specs,
           :name => {:fallback => true},
           :description => {:fallback => false, :base_as_default => false}
    }
  end

  def test_fallbacks
    article = ::Article.create!(:code => 'test-fallback',
                           :name => 'english name fallbacks',
                           :description => 'english desc fallbacks')
    assert_equal 'english name fallbacks', article.name
    assert_equal 'english desc fallbacks', article.description
    assert_equal 'english name fallbacks', article.name_before_type_cast
    assert_equal 'english desc fallbacks', article.description_before_type_cast

    ::Globalize::Locale.set('es','ES')
    assert_equal 'english name fallbacks', article.name
    assert_equal 'english name fallbacks', article.name_before_type_cast
    assert_nil article.description
    assert_nil article.description_before_type_cast

    article.name = "spanish name fallbacks"
    article.save!
    assert_equal 'spanish name fallbacks', article.name
    assert_equal 'spanish name fallbacks', article.name_before_type_cast

    assert_nil article.description
    assert_nil article.description_before_type_cast

    ::Globalize::Locale.set('es-MX','MX')
    assert_equal 'spanish name fallbacks', article.name
    assert_equal 'spanish name fallbacks', article.name_before_type_cast
    assert_nil article.description
    assert_nil article.description_before_type_cast

    ::Globalize::Locale.set('es-MX','MX', [['es','ES'],['en','US']])
    assert_equal 'spanish name fallbacks', article.name
    assert_equal 'spanish name fallbacks', article.name_before_type_cast
    assert_nil article.description
    assert_nil article.description_before_type_cast

    ::Globalize::Locale.set('es-MX','MX', [['en','US'],['es','ES']])
    assert_equal 'english name fallbacks', article.name
    assert_equal 'english name fallbacks', article.name_before_type_cast
    assert_nil article.description
    assert_nil article.description_before_type_cast
  end

  def test_fallbacks_for_base_locale

    ::Globalize::Locale.set_base_language(Language.pick('es-MX'))

    ::Globalize::Locale.set('he','IL')
    article = ::Article.create!(:code => 'test-fallback 2',
                           :name => 'hebrew name fallbacks 2',
                           :description => 'hebrew desc fallbacks 2')
    assert_equal 'hebrew name fallbacks 2', article.name
    assert_equal 'hebrew desc fallbacks 2', article.description
    assert_equal 'hebrew name fallbacks 2', article.name_before_type_cast
    assert_equal 'hebrew desc fallbacks 2', article.description_before_type_cast

    ::Globalize::Locale.set('es-MX','MX')
    assert_nil article.name
    assert_nil article.name_before_type_cast
    assert_nil article.description
    assert_nil article.description_before_type_cast

    ::Globalize::Locale.set('es','ES')
    article.name = 'spanish name fallbacks 2'
    article.description = 'spanish desc fallbacks 2'
    article.save!
    assert_equal 'spanish name fallbacks 2', article.name
    assert_equal 'spanish desc fallbacks 2', article.description
    assert_equal 'spanish name fallbacks 2', article.name_before_type_cast
    assert_equal 'spanish desc fallbacks 2', article.description_before_type_cast

    ::Globalize::Locale.set('es-MX','MX')
    assert_equal 'spanish name fallbacks 2', article.name
    assert_equal 'spanish name fallbacks 2', article.name_before_type_cast
    assert_nil article.description
    assert_nil article.description_before_type_cast

    ::Globalize::Locale.set('es-MX','ES', [['he','IL']])
    assert_equal 'hebrew name fallbacks 2', article.name
    assert_equal 'hebrew name fallbacks 2', article.name_before_type_cast
    assert_nil article.description
    assert_nil article.description_before_type_cast

    ::Globalize::Locale.set_base_language(Language.pick('en'))
  end
end
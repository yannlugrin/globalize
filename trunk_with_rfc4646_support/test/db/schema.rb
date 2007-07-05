ActiveRecord::Schema.define do

  create_table :globalize_simples, :force => true do |t|
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
    t.column :description, :string
    t.column :description_es, :string
    t.column :description_he, :string
    t.column 'description_es_MX', :string
    t.column 'description_es_AR', :string
    t.column 'description_es_419', :string
  end

  create_table :globalize_products, :force => true do |t|
    t.column :code, :string
    t.column :manufacturer_id, :integer
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
    t.column :description, :string
    t.column :description_es, :string
    t.column :description_he, :string
    t.column 'description_es_MX', :string
    t.column 'description_es_AR', :string
    t.column 'description_es_419', :string
    t.column :specs, :string
    t.column :specs_es, :string
    t.column :specs_he, :string
    t.column 'specs_es_MX', :string
    t.column 'specs_es_AR', :string
    t.column 'specs_es_419', :string
  end

  add_index :globalize_products, :code, :unique => true
  add_index :globalize_products, :manufacturer_id


  create_table :globalize_articles, :force => true do |t|
    t.column :code, :string
    t.column :author_id, :integer
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
    t.column :description, :string
    t.column :description_es, :string
    t.column :description_he, :string
    t.column 'description_es_MX', :string
    t.column 'description_es_AR', :string
    t.column 'description_es_419', :string
    t.column :specs, :string
    t.column :specs_es, :string
    t.column :specs_he, :string
    t.column 'specs_es_MX', :string
    t.column 'specs_es_AR', :string
    t.column 'specs_es_419', :string
  end

  add_index :globalize_articles, :code, :unique => true
  add_index :globalize_articles, :author_id

  create_table :globalize_items, :force => true do |t|
    t.column :code, :string
    t.column :order_id, :integer
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
    t.column :description, :string
    t.column :description_es, :string
    t.column :description_he, :string
    t.column 'description_es_MX', :string
    t.column 'description_es_AR', :string
    t.column 'description_es_419', :string
    t.column :specs, :string
    t.column :specs_es, :string
    t.column :specs_he, :string
    t.column 'specs_es_MX', :string
    t.column 'specs_es_AR', :string
    t.column 'specs_es_419', :string
  end

  add_index :globalize_items, :code, :unique => true
  add_index :globalize_items, :order_id

  create_table :globalize_manufacturers, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
  end

  add_index :globalize_manufacturers, :code, :unique

  create_table :globalize_orders, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
  end

  add_index :globalize_orders, :code, :unique

  create_table :globalize_authors, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
  end

  add_index :globalize_authors, :code, :unique

  create_table :globalize_categories, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
  end

  add_index :globalize_categories, :code, :unique


  create_table :globalize_options, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
  end

  add_index :globalize_options, :code, :unique

  create_table :globalize_tags, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column 'name_es_MX', :string
    t.column 'name_es_AR', :string
    t.column 'name_es_419', :string
  end

  add_index :globalize_tags, :code, :unique

  create_table :globalize_categories_products, :id => false, :force => true do |t|
    t.column :category_id, :integer
    t.column :product_id, :integer
  end

  add_index :globalize_categories_products, :category_id
  add_index :globalize_categories_products, :product_id


  create_table :globalize_tags_articles, :id => false, :force => true do |t|
    t.column :tag_id, :integer
    t.column :article_id, :integer
  end

  add_index :globalize_tags_articles, :tag_id
  add_index :globalize_tags_articles, :article_id


  create_table :globalize_options_items, :id => false, :force => true do |t|
    t.column :option_id, :integer
    t.column :item_id, :integer
  end

  add_index :globalize_options_items, :option_id
  add_index :globalize_options_items, :item_id



  create_table :globalize_countries, :force => true do |t|
    t.column :code,               :string, :limit => 2
    t.column :english_name,       :string
    t.column :date_format,        :string
    t.column :currency_format,    :string
    t.column :currency_code,      :string, :limit => 3
    t.column :thousands_sep,      :string, :limit => 1
    t.column :decimal_sep,        :string, :limit => 1
    t.column :currency_decimal_sep,        :string, :limit => 1
    t.column :number_grouping_scheme,      :string
  end
  add_index :globalize_countries, :code

  create_table :globalize_translations, :force => true do |t|
    t.column :type,           :string
    t.column :tr_key,         :string
    t.column :table_name,     :string
    t.column :item_id,        :integer
    t.column :facet,          :string
    t.column :language_id,    :integer
    t.column :pluralization_index,    :integer
    t.column :text,           :text
    t.column :namespace,      :string
  end

  add_index :globalize_translations, [ :tr_key, :language_id ], :name => 'tr_key'
  add_index :globalize_translations, [ :table_name, :item_id, :language_id ], :name => 'table_name'


  create_table :globalize_languages, :force => true do |t|
    t.column :tag, :string
    t.column :primary_subtag, :string
    t.column :english_name, :string
    t.column :native_name, :string
    t.column :direction, :string
    t.column :pluralization, :string
  end

  add_index :globalize_languages, :tag

  create_table :globalize_unlocalized_classes, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
  end

  add_index :globalize_unlocalized_classes, :code, :unique
end
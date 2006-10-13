ActiveRecord::Schema.define do

  create_table :products, :force => true do |t|
    t.column :code, :string
    t.column :manufacturer_id, :integer
    t.column :name, :string
    t.column :description, :string
    t.column :specs, :string
  end

  add_index :products, :code, :unique
  add_index :products, :manufacturer_id

  create_table :manufacturers, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
  end

  add_index :manufacturers, :code, :unique

  create_table :categories, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
  end

  add_index :categories, :code, :unique

  create_table :categories_products, :id => false, :force => true do |t|
    t.column :category_id, :integer
    t.column :product_id, :integer
  end

  add_index :categories_products, :category_id
  add_index :categories_products, :product_id

  create_table :multilingual_countries, :force => true do |t|
    t.column :code,               :string, :limit => 2
    t.column :english_name,       :string
    t.column :number_format,      :string
    t.column :date_format,        :string
    t.column :currency_format,    :string
    t.column :currency_code,      :string, :limit => 3
    t.column :measurement_system, :string
    t.column :thousands_sep,      :string, :limit => 1
    t.column :decimal_sep,        :string, :limit => 1
  end
  add_index :multilingual_countries, :code

  create_table :multilingual_translations, :force => true do |t|
    t.column :type,           :string
    t.column :tr_key,         :string
    t.column :table_name,     :string
    t.column :item_id,        :integer
    t.column :facet,          :string
    t.column :language_id,    :integer
    t.column :text,           :text
  end

  add_index :multilingual_translations, [ :tr_key, :language_id ]
  add_index :multilingual_translations, [ :table_name, :item_id, :language_id ]

  create_table :multilingual_languages, :force => true do |t|
    t.column :iso_639_1, :string, :limit => 2
    t.column :iso_639_2, :string, :limit => 3
    t.column :iso_639_3, :string, :limit => 3
    t.column :rfc_3066,  :string
    t.column :english_name, :string
    t.column :english_name_locale, :string
    t.column :english_name_modifier, :string
    t.column :native_name, :string
    t.column :native_name_locale, :string
    t.column :native_name_modifier, :string
    t.column :macro_language, :boolean
    t.column :direction, :string
    t.column :pluralization, :string
    t.column :scope, :string, :limit => 1
  end

  add_index :multilingual_languages, :iso_639_1, :unique  
  add_index :multilingual_languages, :iso_639_2, :unique  
  add_index :multilingual_languages, :iso_639_3, :unique  
  add_index :multilingual_languages, :rfc_3066,  :unique  

end
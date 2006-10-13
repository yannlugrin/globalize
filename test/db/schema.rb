ActiveRecord::Schema.define do

  create_table :products, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :manufacturer_id, :integer
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

  create_table :translations, :force => true do |t|
    t.column :table_name,     :string
    t.column :item_id,        :integer
    t.column :facet,          :string
    t.column :language_id,    :integer
    t.column :text,           :text
  end

  add_index :translations, [ :table_name, :item_id, :language_id ]

  create_table :languages, :force => true do |t|
    t.column :iso_639_1, :string, :null => false, :limit => 2
    t.column :iso_639_2, :string, :limit => 3
    t.column :iso_639_3, :string, :limit => 3
    t.column :english_name, :string
    t.column :english_name_locale, :string
    t.column :english_name_modifier, :string
    t.column :native_name, :string
    t.column :native_name_locale, :string
    t.column :native_name_modifier, :string
    t.column :macro_language, :boolean
    t.column :scope, :string, :limit => 1
  end

  add_index :languages, :iso_639_1, :unique  
  add_index :languages, :iso_639_2, :unique  
  add_index :languages, :iso_639_3, :unique  

end
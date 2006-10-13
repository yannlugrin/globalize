require File.dirname(__FILE__) + '/test_helper'

class ValidationTest < Test::Unit::TestCase
  include Multilingual

  fixtures :multilingual_languages, :multilingual_countries, :multilingual_translations, :products

  class Product < ActiveRecord::Base
    validates_length_of :name, :minimum => 5
    validates_length_of :specs, :maximum => 10
  end

  def setup
    Multilingual::Locale.set("he-IL")
  end

  def test_max_validation
    prod = Product.find(2)
    assert !prod.valid?
    assert_equal "המפרט ארוך מדי (המקסימום הוא 10 תווים)", prod.errors.full_messages[1]

    prod = Product.find(3)
    assert !prod.valid?
    assert_equal "Name is too short (min is 5 characters)", prod.errors.full_messages.first 
  end
end

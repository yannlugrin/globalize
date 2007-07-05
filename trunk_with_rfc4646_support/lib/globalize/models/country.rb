module Globalize
  class Country < ActiveRecord::Base # :nodoc:
    set_table_name "globalize_countries"

    validates_presence_of :code, :english_name
    validates_uniqueness_of :code

    def self.reloadable?; false end

    def self.pick(country_code)
      raise ArgumentError, "country_code argument is required" if country_code.blank?
      country = find_by_code(country_code)
      country ? country : raise(ArgumentError, "Tag ('#{country_code}') not available in the database. You can add it via: 'Globalize::Country.add()'")
    end

=begin
    t.column :code,               :string, :limit => 2
    t.column :english_name,       :string
    t.column :date_format,        :string
    t.column :currency_format,    :string
    t.column :currency_code,      :string, :limit => 3
    t.column :thousands_sep,      :string, :limit => 1
    t.column :decimal_sep,        :string, :limit => 1
    t.column :currency_decimal_sep,        :string, :limit => 1
    t.column :number_grouping_scheme,      :string

  Create a new Country.
  Syntax:
    Country.add('AT','Austria',nil, '%n €', 'EUR', '.',',',',','western', nil)
    or
    locale = Locale.set('de','DE')
    #The locale's country is used as a template for the new Country
    #(attributes can be overriden)
    Country.add('CH',locale.country,'Switzerland','SFr. %n')
    or
    Country.add('CH',locale,'Switzerland','SFr. %n')
    #The supplied locale's country is used as a template but attributes can be overriden
=end
    def self.add(code, english_name_or_template, english_name=nil,
                 currency_format=nil, currency_code=nil, thousands_sep = nil,
                 decimal_sep = nil, currency_decimal_sep = nil,
                 number_grouping_scheme = nil, date_format=nil)

      options = {:code => code}
      case english_name_or_template
        when Locale, Country
          template_options = {}
          case english_name_or_template
            when Locale
              template_options = english_name_or_template.country.attributes
            when Country
              template_options = english_name_or_template.attributes
          end

          template_options.merge!({:english_name => english_name}) if english_name
          template_options.merge!({:currency_format => currency_format}) if currency_format
          template_options.merge!({:currency_code => currency_code}) if currency_code
          template_options.merge!({:thousands_sep => thousands_sep}) if thousands_sep
          template_options.merge!({:decimal_sep => decimal_sep}) if decimal_sep
          template_options.merge!({:currency_decimal_sep => currency_decimal_sep}) if currency_decimal_sep
          template_options.merge!({:number_grouping_scheme => number_grouping_scheme}) if number_grouping_scheme
          template_options.merge!({:date_format => date_format}) if date_format
          options.reverse_merge!(template_options)
        else
        options.merge(:english_name => english_name_or_template,
                      :date_format => date_format,
                      :currency_format => currency_format,
                      :currency_code => currency_code,
                      :thousands_sep => thousands_sep,
                      :decimal_sep => decimal_sep,
                      :currency_decimal_sep => currency_decimal_sep,
                      :number_grouping_scheme => number_grouping_scheme)
      end
      self.create!(options)
    end

    def number_grouping_scheme
      attr = read_attribute(:number_grouping_scheme)
      attr ? attr.intern : nil
    end
  end
end
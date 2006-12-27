module Globalize # :nodoc:
  module DbLocalize  # :nodoc:

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
=begin rdoc
          Specifies fields that can should be localized. These are normal ActiveRecord
          fields, with corresponding database columns, but that also have a duplicate column
          that is named with the locale language code as a suffix.
          i.e. Apart from the original field's column there should be a column
          for each locale that is to be supported.

          === Example:

          ==== In your model:
            class Product < ActiveRecord::Base
              localizes :name, :description
            end

          ==== In your schema:

              (Assuming english is the base locale, and we want to support spanish)

              create_table :products do |t|
                t.column :id, :integer
                t.column :name, :string
                t.column :name_es, :string
                t.column :description, :string
                t.column :description_es, :string
                ...

              end

          ==== You can now do this:

          Locale.set_base_language('en-US')
          Locale.set('en-US')

          #writes to 'name', 'description' columns
          product = Product.create(:name => 'boots', :description => 'shiny red wellies')

          puts product.name #Accesses name column (english)
          > 'boots'

          Locale.set('es-ES')
          product.name = 'botas'
          product.save
          puts product.name #Accesses name_es column (spanish),
          > 'botas'

          puts product._name #Accesses original 'title' column
          > 'boots'

          Locale.set('en-US')
          puts product.name #Accesses name column (english)
          > 'boots'


          You can create any 'find' query you want without limitation.

          A further feature:

          Locale.set('es-ES')
          product = Product.find_by_name('botas')
          puts product.name
          > 'botas'

          Locale.set('en-US')
          product = Product.find_by_name('boots')
          puts product.name
          > 'boots'

          Locale.set('es-ES')
          puts product.name
          > 'botas'


          Note: The column name suffix that should be used to name the localized
          columns (in example Spanish) is that returned by:

          Locale.new('es-ES').language.code (For this example)


          Differences with using 'translates':

             - This method avoids any extra joins (and thus the limitations to
               ActiveRecord::Base#find that using 'translates' applies)

             - This also means that you have all the localized versions of
               your model instance's data in one query.

             - Changing locale doesn't necesitate a reload of the model object in
               order to access the localized data for the new locale.

             - Having to maintain all those extra columns may prove to be a
               maintenance problem but by using ActiveRecord migrations this
               should be painless.

          Inspired by Xavier Defrang (http://defrang.com/articles/2005/12/02/playing-with-rails-i18n)
=end
      def localizes(*facets)

        # parse out options hash
        options = facets.pop if facets.last.kind_of? Hash
        options ||= {:base_as_default => false}

        facets_string = "[" + facets.map {|facet| ":#{facet}"}.join(", ") + "]"
        class_eval %{
          @@globalize_facets = #{facets_string}

          def self.globalize_facets
            @@globalize_facets
          end

          def globalize_facets_hash
            @@globalize_facets_hash ||= globalize_facets.inject({}) {|hash, facet|
              hash[facet.to_s] = true; hash
            }
          end

          def non_localized_fields
            @@non_localized_fields ||=
              column_names.map {|cn| cn.intern } - globalize_facets
          end

          #Is field translated?
          #Returns true if translated
          #Warning! Depends on Locale.switch_locale
          def translated?(facet, locale_code = nil)
            localized_method = "\#{facet}_\#{Locale.active.language.code}"

            Locale.switch_locale(locale_code) do
              localized_method = "\#{facet}_\#{Locale.active.language.code}"
            end if locale_code

            value = send(localized_method.to_sym) if respond_to?(localized_method.to_sym)
            return !value.nil?
          end
        }

        facets.each do |facet|
          class_eval %{

            #Accessor that proxies to the right accessor for the current locale
            def #{facet}
              unless Locale.base?
                localized_method = "#{facet}_\#{Locale.active.language.code}"
                value = send(localized_method.to_sym) if respond_to?(localized_method.to_sym)
                value = value ? value : read_attribute(:#{facet}) if #{options[:base_as_default]}
                return value
              end
              read_attribute(:#{facet})
            end

            #Accessor before typecasting that proxies to the right accessor for the current locale
            def #{facet}_before_type_cast
              unless Locale.base?
                localized_method = "#{facet}_\#{Locale.active.language.code}_before_type_cast"
                value = send(localized_method.to_sym) if respond_to?(localized_method.to_sym)
                value = value ? value : read_attribute_before_type_cast('#{facet}') if #{options[:base_as_default]}
                return value
              end
              read_attribute_before_type_cast('#{facet}')
            end

            #Write to appropriate localized attribute
            def #{facet}=(value)
              unless Locale.base?
                localized_method = "#{facet}_\#{Locale.active.language.code}"
                write_attribute(localized_method.to_sym, value) if respond_to?(localized_method.to_sym)
              else
                write_attribute(:#{facet}, value)
              end
            end

            #Is field translated?
            #Returns true if untranslated
            def #{facet}_is_base?
              localized_method = "#{facet}_\#{Locale.active.language.code}"
              value = send(localized_method.to_sym) if respond_to?(localized_method.to_sym)
              return value.nil?
            end

            #Read base language attribute directly
            def _#{facet}
              read_attribute(:#{facet})
            end

            #Read base language attribute directly without typecasting
            def _#{facet}_before_type_cast
              read_attribute_before_type_cast('#{facet}')
            end

            #Write base language attribute directly
            def _#{facet}=(value)
              write_attribute(:#{facet}, value)
            end
          }
        end

        #Returns the localized_name of the supplied attribute for the
        #current locale
        #Useful when you have to build up sql by hand or for AR::Base::find conditions
        def localized_facet(facet)
          unless Locale.base?
            "#{facet}_#{Locale.active.language.code}"
          else
            facet.to_s
          end
        end

        # Overridden to ensure that dynamic finders using localized attributes
        # like find_by_user_name(user_name) or find_by_user_name_and_password(user_name, password)
        # use the appropriately localized column.
        def method_missing(method_id, *arguments)
          if match = /find_(all_by|by)_([_a-zA-Z]\w*)/.match(method_id.to_s)
            finder, deprecated_finder = determine_finder(match), determine_deprecated_finder(match)

            facets = extract_facets_from_match(match)
            super unless all_attributes_exists?(facets)

            #Overrride facets to use appropriate attribute name for current locale
            facets.collect! {|attr_name| respond_to?(:globalize_facets) && globalize_facets.include?(attr_name.intern) ? localized_facet(attr_name) : attr_name}

            attributes = construct_attributes_from_arguments(facets, arguments)

            case extra_options = arguments[facets.size]
              when nil
                options = { :conditions => attributes }
                set_readonly_option!(options)
                ActiveSupport::Deprecation.silence { send(finder, options) }

              when Hash
                finder_options = extra_options.merge(:conditions => attributes)
                validate_find_options(finder_options)
                set_readonly_option!(finder_options)

                if extra_options[:conditions]
                  with_scope(:find => { :conditions => extra_options[:conditions] }) do
                    ActiveSupport::Deprecation.silence { send(finder, finder_options) }
                  end
                else
                  ActiveSupport::Deprecation.silence { send(finder, finder_options) }
                end

              else
                ActiveSupport::Deprecation.silence do
                  send(deprecated_finder, sanitize_sql(attributes), *arguments[facets.length..-1])
                end
            end
          elsif match = /find_or_(initialize|create)_by_([_a-zA-Z]\w*)/.match(method_id.to_s)
            instantiator = determine_instantiator(match)
            facets = extract_facets_from_match(match)
            super unless all_attributes_exists?(facets)

            attributes = construct_attributes_from_arguments(facets, arguments)
            options = { :conditions => attributes }
            set_readonly_option!(options)

            find_initial(options) || send(instantiator, attributes)
          else
            super
          end
        end
      end

      alias_method :localises, :localizes
    end
  end

end
module Multilingual # :nodoc:
  module DbTranslate  # :nodoc:

    def self.included(base)
      base.extend(ClassMethods)
    end

    class WrongLanguageError < ActiveRecord::ActiveRecordError; end
    class TranslationTrampleError < ActiveRecord::ActiveRecordError; end

    module ClassMethods
=begin rdoc
          Specifies fields that can be translated. These fields are stored in a
          special translations tables, not in the model table.
          
          === Example:
          
          ==== In model:
            class Product < ActiveRecord::Base
              translates :name, :description
            end
          
          ==== In controller:
            Locale.set("en_US")
            product.name -> guitar
            
            Locale.set("es_ES")
            product.name -> guitarra
=end
      def translates(*facets)

        facets_string = "[" + facets.map {|facet| ":#{facet}"}.join(", ") + "]"
        class_eval <<-HERE
          attr_writer :fully_loaded
          def fully_loaded?; @fully_loaded; end
          @@multilingual_facets = #{facets_string}
          @@preload_facets ||= [ @@multilingual_facets.first ]
#          @@preload_facets ||= @@multilingual_facets
          class << self

            def sqlite?; connection.kind_of? ActiveRecord::ConnectionAdapters::SQLiteAdapter end

            def multilingual_facets
              @@multilingual_facets
            end

            def multilingual_facets_hash
              @@multilingual_facets_hash ||= multilingual_facets.inject({}) {|hash, facet|
                hash[facet.to_s] = true; hash
              }
            end            

            def untranslated_fields
              @@untranslated_fields ||= 
                column_names.map {|cn| cn.intern } - multilingual_facets
            end

            def preload_facets; @@preload_facets; end
            def postload_facets
              @@postload_facets ||= @@multilingual_facets - @@preload_facets
            end
            alias_method :multilingual_old_find, :find unless
              respond_to? :multilingual_old_find
          end
          alias_method :multilingual_old_reload, :reload
          alias_method :multilingual_old_create_or_update, :create_or_update
        
          include Multilingual::DbTranslate::TranslateObjectMethods
          extend  Multilingual::DbTranslate::TranslateClassMethods        

        HERE

        facets.each do |facet|
          class_eval <<-HERE
            def #{facet}
              if not_original_language
                raise WrongLanguageError, 
                  "object was loaded as \#{@original_language.english_name}, " +
                  "referenced as \#{Language.active_language.english_name}"
              end
              load_other_translations if 
                !fully_loaded? && !self.class.preload_facets.include?(:#{facet})
              read_attribute(:#{facet})
            end

            def #{facet}=(arg)
              raise WrongLanguageError, 
                "object was loaded as \#{@original_language.english_name}, " +
                "can't modify as \#{Language.active_language.english_name}" if
                not_original_language
              write_attribute(:#{facet}, arg)
            end
          HERE
        end

      end

=begin rdoc
      Optionally specifies translated fields to be preloaded on <tt>find</tt>. For instance,
      in a product catalog, you may want to do a <tt>find</ff> of the first 10 products:

        Product.find(:all, :limit => 10, :order => "name"

      But you wouldn't want to load the complete descriptions and specs of all the
      products, just the names and summaries. So you'd specify:

        class Product < ActiveRecord::Base
          translates :name, :summary, :description, :specs
          translates_preload :name, :summary
          ...
        end

      By default (if no translates_preload is specified), Multilingual will preload
      the first field given to <tt>translates</tt>. It will also fully load on
      a <tt>find(:first)</tt> or when <tt>:translate_all => true</tt> is given as a find option.
=end
      def translates_preload(*facets)
      module_eval <<-HERE
        @@preload_facets = facets
      HERE
      end

    end

    module TranslateObjectMethods # :nodoc: all

      module_eval <<-HERE
      def not_original_language
        !@original_language.nil? && 
          (@original_language != Language.active_language)
      end

      def set_original_language
        @original_language = Language.active_language      
      end
      HERE

      def load_other_translations
        postload_facets = self.class.postload_facets
        return if postload_facets.empty? || new_record?

        table_name = self.class.table_name
        facet_selection = postload_facets.join(", ")
        base = connection.select_one("SELECT #{facet_selection} " +
          " FROM #{table_name} WHERE #{self.class.primary_key} = #{id}", 
          "loading base for load_other_translations")
        base.each {|key, val| write_attribute( key, val ) }

        if !Language.base?
          trs = Translation.find(:all, 
            :conditions => [ "table_name = ? AND item_id = ? AND language_id = ? AND " +
            "facet IN (#{[ '?' ] * postload_facets.size * ', '})", table_name,
            self.id, Language.active_language.id ] + postload_facets.map {|facet| facet.to_s} )
          trs ||= []
          trs.each do |tr|
            attr = tr.text || base[tr.facet.to_s]
            write_attribute( tr.facet, attr )
          end
        end
        self.fully_loaded = true
      end

      def reload
        multilingual_old_reload
        set_original_language
      end

      private  
      
        # Returns copy of the attributes hash where all the values have been safely quoted for use in
        # an SQL statement.
        # REDEFINED to include only untranslated fields. We don't want to overwrite the 
        # base translation with other translations.
        def attributes_with_quotes(include_primary_key = true)
          if Language.base?
            attributes.inject({}) do |quoted, (name, value)|
              if column = column_for_attribute(name)
                quoted[name] = quote(value, column) unless !include_primary_key && column.primary
              end
              quoted
            end
          else
            attributes.inject({}) do |quoted, (name, value)|
              if !self.class.multilingual_facets_hash.has_key?(name) && 
                  column = column_for_attribute(name)
                quoted[name] = quote(value, column) unless !include_primary_key && column.primary
              end
              quoted
            end
          end          
        end

        def create_or_update
          multilingual_old_create_or_update
          update_translation
        end
        
        def update_translation
          raise WrongLanguageError, 
            "object was loaded as #{@original_language.english_name}, " +
            "can't save as #{Language.active_language.english_name}" if
            not_original_language

          language_id = Language.active_language.id
          base_language_id = Language.base_language.id

          set_original_language

          # nothing to do, facets updated in main model
          return if Language.base?

          table_name = self.class.table_name
          self.class.multilingual_facets.each do |facet|
            next if !has_attribute?(facet)
            text = read_attribute(facet)
            tr = Translation.find(:first, :conditions =>
              [ "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
              table_name, id, facet.to_s, language_id ])
            if tr.nil?
              # create new record
              Translation.create(:table_name => table_name, 
                :item_id => id, :facet => facet.to_s, 
                :language_id => language_id,
                :text => text) if !text.nil?
            elsif text.nil?
              # delete record
              tr.destroy
            else
              # update record
              tr.update_attribute(:text, text) if tr.text != text
            end
          end # end facets loop
        end

    end

    module TranslateClassMethods  # :nodoc: all
      
      def untranslated_find(*args)
        has_options = args.last.is_a?(Hash)
        options = has_options ? args.last : {}
        options[:untranslated] = true
        args << options if !has_options
        multilingual_old_find(*args)
      end

      def find(*args)
        options = args.last.is_a?(Hash) ? args.last : {}

        return multilingual_old_find(*args) if options[:untranslated]

        find_type = args.first
        if find_type == :first
          options[:translate_all] = true
          return multilingual_old_find(:first, options)
        elsif find_type != :all
          return multilingual_old_find(*args)
        end

        raise StandardError, 
          ":select option not allowed on translatable models" if options.has_key?(:select)

        untranslated_find(*args) if Language.base?

        options[:conditions] = fix_conditions(options[:conditions]) if options[:conditions]

        language_id = Language.active_language.id
        base_language_id = Language.base_language.id

        load_full = options[:translate_all]
        facets = load_full ? multilingual_facets : preload_facets
        select_clause = untranslated_fields.map {|f| "#{table_name}.#{f}" }.join(", ")
        joins_clause = options[:joins].nil? ? "" : options[:joins].dup
        joins_args = []

=begin
        There's a bug in sqlite that messes up sorting when aliasing fields, 
        see: <http://www.sqlite.org/cvstrac/tktview?tn=1521,33>.

        Since I want to use sqlite, and sorting, I'm hacking this to make it work.
        This involves renaming order by fields and adding them to the SELECT part. 
        It's a sucky hack, but hopefully sqlite will fix the bug soon.
=end

        # sqlite bug hack          
        select_position = untranslated_fields.size

        facets.each do |facet| 
          facet = facet.to_s
          facet_table_alias = "t_#{facet}"

          # sqlite bug hack          
          select_position += 1
          options[:order].sub!(/\b#{facet}\b/, select_position.to_s) if options[:order] if sqlite?

          select_clause << ", COALESCE(#{facet_table_alias}.text, #{table_name}.#{facet}) AS #{facet} " 
          joins_clause  << " LEFT OUTER JOIN translations AS #{facet_table_alias} " +
            "ON #{facet_table_alias}.table_name = ? " +
            "AND #{table_name}.#{primary_key} = #{facet_table_alias}.item_id " +
            "AND #{facet_table_alias}.facet = ? AND #{facet_table_alias}.language_id = ?"
          joins_args << table_name << facet << language_id            
        end

        # add in associations (of :belongs_to nature) if applicable
        associations = options[:include_translated] || []
        associations = [ associations ].flatten
        associations.each do |assoc|
          rfxn = reflect_on_association(assoc)
          assoc_type = rfxn.macro
          raise StandardError, 
            ":include_translated associations must be of type :belongs_to;" +
            "#{assoc} is #{assoc_type}" if assoc_type != :belongs_to
          klass = rfxn.klass
          assoc_facets = klass.preload_facets
          included_table = klass.table_name
          included_fk = klass.primary_key
          assoc_facets.each do |facet|
            facet_table_alias = "t_#{assoc}_#{facet}"
            fk = rfxn.options[:foreign_key] || "#{assoc}_id"
            select_clause << ", COALESCE(#{facet_table_alias}.text, #{included_table}.#{facet}) " +
              "AS #{assoc}_#{facet} "
            joins_clause << " LEFT OUTER JOIN translations AS #{facet_table_alias} " +
              "ON #{facet_table_alias}.table_name = ? " +
              "AND #{table_name}.#{fk} = #{facet_table_alias}.item_id " +
              "AND #{facet_table_alias}.facet = ? AND #{facet_table_alias}.language_id = ? " +
              "LEFT OUTER JOIN #{included_table} " + 
              "ON #{table_name}.#{fk} = #{included_table}.#{included_fk} "
            joins_args << klass.table_name << facet.to_s << language_id
          end
        end

        options[:select] = select_clause
        options[:readonly] = false

        sanitized_joins_clause = sanitize_sql( [ joins_clause, *joins_args ] )        
        options[:joins] = sanitized_joins_clause
        results = multilingual_old_find(:all, options)

        results.each {|result| 
          result.set_original_language
          result.fully_loaded = true if load_full
        }
      end

      protected
        def validate_find_options(options)
          options.assert_valid_keys [ :conditions, :include, :include_translated, 
            :joins, :limit, :offset, :order, :select, :readonly, :translate_all,
            :untranslated ]
        end

      private

        # properly scope conditions to table
        def fix_conditions(conditions)
          if conditions.kind_of? Array          
            is_array = true
            sql = conditions.shift
          else
            is_array = false
            sql = conditions
          end
          column_names.each do |column_name|
            sql.gsub!(/([^\.\w])(#{column_name})(\W)/, '\1' + table_name + '.\2\3')
          end
          if is_array
            [ sql ] + conditions
          else
            sql
          end
        end

    end
  end

end

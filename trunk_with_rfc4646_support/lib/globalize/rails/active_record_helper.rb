module ActionView
  module Helpers
    module ActiveRecordHelper
      # Returns a string with a div containing all the error messages for the object located as an instance variable by the name
      # of <tt>object_name</tt>. This div can be tailored by the following options:
      #
      # * <tt>header_tag</tt> - Used for the header of the error div (default: h2)
      # * <tt>id</tt> - The id of the error div (default: errorExplanation)
      # * <tt>class</tt> - The class of the error div (default: errorExplanation)
      #
      # NOTE: This is a pre-packaged presentation of the errors with embedded strings and a certain HTML structure. If what
      # you need is significantly different from the default presentation, it makes plenty of sense to access the object.errors
      # instance yourself and set it up. View the source of this method to see how easy it is.
      #
      # Retrofitted for Globalize by Andr� Camargo
      def error_messages_for(*params)
        options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
        objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        count   = objects.inject(0) {|sum, object| sum + object.errors.count }
        unless count.zero?
          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end
          header_message = "#{pluralize(count, 'error')} prohibited this #{(options[:object_name] || params.first).to_s.gsub('_', ' ').t} from being saved"
          error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }
          content_tag(:div,
            content_tag(options[:header_tag] || :h2, header_message) <<
              content_tag(:p, 'There were problems with the following fields:'.t) <<
              content_tag(:ul, error_messages),
            html
          )
        else
          ''
        end
      end
    end
  end
end

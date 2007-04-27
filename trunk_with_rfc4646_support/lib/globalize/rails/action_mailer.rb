# Search for translated templates or fall back to the default one
module ActionMailer # :nodoc:

  # Globalize overrides the create! method to support multiple templates
  # for different locales. For example, for English it will select the template:
  #   signup_notification.en-US.text.html.rhtml
  #
  # It will look for the currently active locale code (en-US) first,
  # then the language code (en).
  #
  # If neither of those are found, it will use the regular name:
  #   signup_notification.text.html.rhtml
  #
  # It is fully backwards compatible with the original Rails version.
  class Base

    # Initialize the mailer via the given +method_name+. The body will be
    # rendered and a new TMail::Mail object created.
    #
    # This method is overriden by Globalize to support multiple templates
    # for different locales. For example, use:
    #   signup_notification.en-US.text.html.rhtml
    # It is fully backwards compatible with the original rails version.
    def create!(method_name, *parameters) #:nodoc:
      initialize_defaults(method_name)
      send(method_name, *parameters)

      # If an explicit, textual body has not been set, we check assumptions.
      unless String === @body
        # First, we look to see if there are any likely templates that match,
        # which include the content-type in their file name (i.e.,
        # "the_template_file.text.html.rhtml", etc.). Only do this if parts
        # have not already been specified manually.
        if @parts.empty?
          append_localized_parts
          unless @parts.empty?
            @content_type = "multipart/alternative"
            @charset = nil
            @parts = sort_parts(@parts, @implicit_parts_order)
          end
        end

        # Then, if there were such templates, we check to see if we ought to
        # also render a "normal" template (without the content type). If a
        # normal template exists (or if there were no implicit parts) we render
        # it.
        render_localized_normal_template

        # Finally, if there are other message parts and a textual body exists,
        # we shift it onto the front of the parts and set the body to nil (so
        # that create_mail doesn't try to render it in addition to the parts).
        if !@parts.empty? && String === @body
          @parts.unshift Part.new(:charset => charset, :body => @body)
          @body = nil
        end
      end

      # If this is a multipart e-mail add the mime_version if it is not
      # already set.
      @mime_version ||= "1.0" if !@parts.empty?

      # build the mail object itself
      @mail = create_mail

    end

    private
      def append_localized_parts
        valid_mime_types = %w(application audio example image message model multipart text video)
        codes = locale_codes
        codes.each do |code|
          if code
            templates = Dir.glob("#{template_path}/#{@template}.#{code}.*")
          else
            #debugger
            templates = Dir.glob("#{template_path}/#{@template}.*")
          end
          templates.each do |path|
            sections = File.basename(path).split(".")[0..-2] || []

            #Globalize::Locale.possible_code?
            # skip if this is some other language
            next if !code && ((sections.size >= 3) && (!valid_mime_types.include?(sections[1])) || (sections.size == 2))

            # skip either template name and locale, or just template name
            type_sections = code ? sections[2..-1] : sections[1..-1]
            type = type_sections.join("/")

            next if type.empty?
            @parts << Part.new(:content_type => type,
              :disposition => "inline", :charset => charset,
              :body => render_message(sections.join('.'), @body))
          end


          # if we found templates at this stage, no need to continue to defaults
          break if !templates.empty?
        end
      end

      def render_localized_normal_template
        #template_exists = @parts.empty?
        template_exists = false
        path_to_template = template_path[0..1] == './' ? template_path[2..-1] : template_path
        codes = locale_codes
        codes.each do |code|
          localized_name = @template
          if !template_exists
            if code
              localized_name = [ @template, code ].join(".")
              template_exists ||=
                Dir.glob("#{path_to_template}/#{localized_name}.*").any? { |i| i.split(".").length == 3 }
            else
              template_exists ||=
                Dir.glob("#{path_to_template}/#{@template}.*").any? { |i| i.split(".").length == 2 }
            end
          end
          @body = render_message(localized_name, @body) if template_exists
          break if template_exists
        end
      end

      def locale_codes
        loc = Globalize::Locale.active
        codes = Globalize::Locale.active.possible_codes(true) if loc
        codes ||= []
        codes << nil # look for default path, with no localization
      end
  end
end

# Search for translated templates or fall back to the default one
module ActionView # :nodoc: all
  class Base
    alias_method :globalize_old_render_file, :render_file

    # Name of file extensions which are handled internally in rails. Other types
    # like liquid has to register through register_handler.
    @@re_extension = /\.(rjs|rhtml|rxml)$/

    @@globalize_path_cache = {}

    def render_file(template_path, use_full_path = true, local_assigns = {})
      @first_render ||= template_path

      if Globalize::Locale.active?
        localized_path = locate_globalize_path(template_path, use_full_path)
        # don't use_full_path -- we've already expanded the path
        globalize_old_render_file(localized_path, false, local_assigns)
      else
        globalize_old_render_file(template_path, use_full_path, local_assigns)
      end
    end

    private

      # Override because the original version is too minimalist
      def path_and_extension(template_path) #:nodoc:
        template_path_without_extension = template_path.sub(@@re_extension, '')
        [ template_path_without_extension, $1 ]
      end

      def locate_globalize_path(template_path, use_full_path)

        locale_codes = Globalize::Locale.active.possible_codes(true)

        cache_key = nil
        locale_codes.each do |code|
          cache_key = "#{code}:#{template_path}"
          cached = @@globalize_path_cache[cache_key]
          return cached if cached
        end

        if use_full_path
          template_path_without_extension, template_extension = path_and_extension(template_path)

          if template_extension
            template_file_name = full_template_path(template_path_without_extension, template_extension)
          else
            template_extension = pick_template_extension(template_path).to_s
            template_file_name = full_template_path(template_path, template_extension)
          end
        else
          template_file_name = template_path
          template_extension = template_path.split('.').last
        end

        pn = Pathname.new(template_file_name)
        dir, filename = pn.dirname, pn.basename('.' + template_extension)

        localized_path = nil
        locale_codes.each do |code|
          cache_key = "#{code}:#{template_path}"

          localized_path = dir +
            (filename.to_s + '.' + code + '.' + template_extension)
          localized_path = nil unless localized_path.exist?
          break if localized_path && localized_path.exist?
        end

        return template_file_name unless localized_path
        @@globalize_path_cache[cache_key] = localized_path.to_s
      end

  end
end

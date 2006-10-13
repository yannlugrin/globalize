# Rewrite the country selection helper-functions to use iso3166 numeric codes
# instead of hardcoded names and make them translatable. This may break old
# code but it's worth it. The old way is broken.
module ActionView::Helpers
  module FormOptionsHelper
    def country_select(object, method, options = {}, html_options = {})
      InstanceTag.new(object, method, self).to_country_select_tag(options, html_options)
    end

    def country_options_for_select(selected = nil, options = {})
      country_options = ""

      countries = (options[:countries] || Locale.countries).collect do |c,s|
        [(options[:variant] == :formal ? s[:formal] : s[:common]), c]
      end

      options[:prioritized].collect! {|code| (MLR_ISO3166_CODE || DEFAULT_MLR_ISO3166_CODE).to_s == 'numeric' ? code.to_i : code.to_s.upcase } if options[:prioritized]
      options[:only].collect! {|code| (MLR_ISO3166_CODE || DEFAULT_MLR_ISO3166_CODE).to_s == 'numeric' ? code.to_i : code.to_s.upcase } if options[:only]
      options[:exclude].collect! {|code| (MLR_ISO3166_CODE || DEFAULT_MLR_ISO3166_CODE).to_s == 'numeric' ? code.to_i : code.to_s.upcase } if options[:exclude]

      if options[:swap_parts]
        countries.collect! do |a|
          if a[0] =~ /^[A-Z].*-$/
            a[0] = a[0][0...-1].split('')
            a[0][0].downcase!
            a[0] = a[0].join.split(/\s*,\s*/).reverse.join
          else
            a[0] = a[0].split(/\s*,\s*/).reverse.join(' ')
          end
          a
        end
      end

      countries.sort! {|a,b| a[0] <=> b[0]}

      if options[:prioritized]
        country_options += options_for_select(countries.reject{|a| !options[:prioritized].include?(a[1])}, selected)
        country_options += "<option value=\"\">-------------</option>\n"
      end

      countries.delete_if {|a| !options[:only].include?(a[1]) } if options[:only]
      countries.delete_if {|a| options[:exclude].include?(a[1]) } if options[:exclude]

      if options[:prioritized] && options[:prioritized].include?(selected)
        country_options += options_for_select(countries.reject{|a| options[:prioritized].include?(a[1])}, selected)
      else
        country_options += options_for_select(countries, selected)
      end

      return country_options
    end
  end

  class InstanceTag
    def to_country_select_tag(options, html_options)
      html_options = html_options.stringify_keys
      add_default_name_and_id(html_options)
      content_tag("select", add_options(country_options_for_select(value, options), options, value), html_options)
    end
  end
end

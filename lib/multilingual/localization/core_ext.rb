# This module supplies a bunch of localization-related core extensions to ruby 
# built-in and standard classes.

module Multilingual # :nodoc:
  module CoreExtensions

    module String

      # Translates the string into the active language. If there is a 
      # quantity involved, it can be set with the +num+ parameter. In this case 
      # string should contain the code <tt>%d</tt>, which will be substituted with
      # the supplied number.
      #
      # If there is no translation available, +default+ will be returned, or
      # if it's not supplied, the original string will be returned.
      def translate(num = nil, default = nil)
        Locale.translate(self, num, default)
      end
      alias :t :translate

      # Translates the string into the active language. This is equivalent
      # to translate(num).
      #
      # Example: <tt>"There are %d items in your cart" / 1 -> "There is one item in your cart"</tt>
      def /(num)
        translate(num)
      end
    end

    module Symbol
      # Translates the symbol into the active language. Underscores are 
      # converted to spaces.
      #
      # If there is no translation available, +default+ will be returned, or
      # if it's not supplied, the original string will be returned.
      def translate(default = nil)
        Locale.translate(self, nil, default)
      end
      alias :t :translate
    end

    module Object
      # Translates the supplied string into the active language. If there is a 
      # quantity involved, it can be set with the +num+ parameter. In this case 
      # string should contain the code <tt>%d</tt>, which will be substituted with
      # the supplied number.
      #
      # If there is no translation available, +default+ will be returned, or
      # if it's not supplied, the original string will be returned.
      #
      # <em>Note: This method is deprectated and is supplied for backward
      # compatibility with other translation packages, notable gettext.</em>
      def _(str, num = nil, default = nil)
        Locale.translate(str, num, default)        
      end
    end

    module Integer
      # Returns the integer in String form, according to the rules of the
      # currently active locale.
      def localized( base = 10 )
        str = self.unlocalized( base )
        if (base == 10) && Locale.active?
          active_locale = Locale.active
          delimiter = active_locale.thousands_sep || ','
          active_locale.number_grouping_scheme == :indian ?
            str.gsub(/(\d)(?=((\d\d\d)(?!\d))|((\d\d)+(\d\d\d)(?!\d)))/, 
              "\\1#{delimiter}") :
            str.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
        else
          str
        end
      end
    end

    module Float
      # Returns the integer in String form, according to the rules of the
      # currently active locale.
      #
      # Example: <tt>123456.localized -> 123.456</tt> (German locale)
      def localized
        str = self.unlocalized
        if Locale.active? && str =~ /^[\d\.]+$/
          active_locale = Locale.active
          delimiter = active_locale.thousands_sep || ','
          decimal   = active_locale.decimal_sep   || '.'
          int, frac = str.split('.')
          active_locale.number_grouping_scheme == :indian ?
            int.gsub!(/(\d)(?=((\d\d\d)(?!\d))|((\d\d)+(\d\d\d)(?!\d)))/, 
              "\\1#{delimiter}") :
            int.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
          int + decimal + frac
        else
          str
        end
      end
    end

    module Time
      def localized_strftime(format)
        # unabashedly stole this snippet from Tadayoshi Funaba's Date class
        o = ''
        format.scan(/%[EO]?.|./o) do |c|
          cc = c.sub(/^%[EO]?(.)$/o, '%\\1')
          case cc
          when '%A'; o << "#{::Date::DAYNAMES[wday]} [weekday]".t(::Date::DAYNAMES[wday])
          when '%a'; o << "#{::Date::ABBR_DAYNAMES[wday]} [abbreviated weekday]".t(::Date::ABBR_DAYNAMES[wday])
          when '%B'; o << "#{::Date::MONTHNAMES[mon]} [month]".t(::Date::MONTHNAMES[mon])
          when '%b'; o << "#{::Date::ABBR_MONTHNAMES[mon]} [abbreviated month]".t(::Date::ABBR_MONTHNAMES[mon])
          when '%c'; o << (Locale.active? && Locale.active.date_format) ? 
            localized_strftime(Locale.active.date_format) : unlocalized_strftime('%c')
          when '%p'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("AM") else 'PM [Post Meridiem]'.t("PM") end
          else;      o << c
          end
        end
        unlocalized_strftime(o)
      end                
    end
    
    module Date
      def localized_strftime(format)
        # unabashedly stole this snippet from Tadayoshi Funaba's Date class
        o = ''
        format.scan(/%[EO]?.|./o) do |c|
          cc = c.sub(/^%[EO]?(.)$/o, '%\\1')
          case cc
          when '%A'; o << "#{::Date::DAYNAMES[wday]} [weekday]".t(::Date::DAYNAMES[wday])
          when '%a'; o << "#{::Date::ABBR_DAYNAMES[wday]} [abbreviated weekday]".t(::Date::ABBR_DAYNAMES[wday])
          when '%B'; o << "#{::Date::MONTHNAMES[mon]} [month]".t(::Date::MONTHNAMES[mon])
          when '%b'; o << "#{::Date::ABBR_MONTHNAMES[mon]} [abbreviated month]".t(::Date::ABBR_MONTHNAMES[mon])
          when '%c'; o << (Locale.active? && Locale.active.date_format) ? 
            localized_strftime(Locale.active.date_format) : unlocalized_standard_strftime('%c')
          when '%p'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("am") else 'PM [Post Meridiem]'.t("am") end
          when '%P'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("AM") else 'PM [Post Meridiem]'.t("PM") end
          else;      o << c
          end
        end
        unlocalized_strftime(o)
      end                
    end

  end
end

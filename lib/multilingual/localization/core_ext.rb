# This module supplies a bunch of localization-related core extensions to ruby 
# built-in and standard classes.

module Multilingual
  module CoreExtensions

    module String
      def translate(num = nil, default = nil)
        Locale.translator.fetch(self, num, default)
      end
      alias :t :translate

      def /(num)
        translate(num)
      end
    end

    module Symbol
      def translate(default = nil)
        Locale.translator.fetch(self, nil, default)
      end
      alias :t :translate
    end

    module Object
      def _(str, num = nil, default = nil)
        Locale.translator.fetch(str, num, default)        
      end
    end

    module Fixnum
      def multilingual_new_to_s( base = 10)
        str = self.multilingual_old_to_s( base )
        if (base == 10) && Locale.active?
          delimiter = Locale.active.thousands_sep
          str.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
        else
          str
        end
      end
    end

    module Bignum
      def multilingual_new_to_s( base = 10)
        str = self.multilingual_old_to_s( base )
        if (base == 10) && Locale.active?
          delimiter = Locale.active.thousands_sep
          str.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
        else
          str
        end
      end
    end

    module Float
      def multilingual_new_to_s
        str = self.multilingual_old_to_s
        if Locale.active? && str =~ /^[\d\.]+$/
          delimiter = Locale.active.thousands_sep || ','
          decimal   = Locale.active.decimal_sep   || '.'
          int, frac = str.split('.')
          int.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
          int + decimal + frac
        else
          str
        end
      end
    end

    module Time
      def multilingual_new_strftime(format)
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
            strftime(Locale.active.date_format) : multilingual_old_strftime('%c')
          when '%p'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("AM") else 'PM [Post Meridiem]'.t("PM") end
          else;      o << c
          end
        end
        multilingual_old_strftime(o)
      end                
    end
    
    module Date
      def multilingual_new_strftime(format)
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
            strftime(Locale.active.date_format) : multilingual_old_strftime('%c')
          when '%p'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("am") else 'PM [Post Meridiem]'.t("am") end
          when '%P'; o << if hour < 12 then 'AM [Ante Meridiem]'.t("AM") else 'PM [Post Meridiem]'.t("PM") end
          else;      o << c
          end
        end
        multilingual_old_strftime(o)
      end                
    end

  end
end
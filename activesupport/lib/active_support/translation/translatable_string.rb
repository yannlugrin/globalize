module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    module TranslatableString #:nodoc:
      
      PLURALIZATION_REGEXP = /(%d\s+[^\s]+)/
      DOWN_CASE_VERBAL_PLURALIZATION_REGEXP = /(are\s+%d\s+[^\s]+)/
      UP_CASE_VERBAL_PLURALIZATION_REGEXP = /(Are\s+(.*)\s+%d\s+[^\s]+)/
      
      # translates the supplied string
      #
      # Default implementation allows:
      #
      #  * simple/multiple string interpolation via %s
      #     
      #    e.g. "%s loves rails".t('G. W. Bush') => 'G. W. Bush loves rails'
      #         "%s and %s love rails".t('G. W. Bush', 'J. Edgar Hoover') => 'G. W. Bush and J. Edgar Hoover love rails'
      #
      #  * simple pluralization via %d (with/out string interpolation)
      #
      #   e.g. "%d errors prohibited this pizza from being saved".t(1) => '1 error prohibited this pizza from being saved'
      #        "%d errors prohibited this pizza from being saved".t(10) => '10 errors prohibited this pizza from being saved'
      #
      #        "%d errors prohibited this %s from being saved".t(1,'penguin') => '1 error prohibited this penguin from being saved'
      #        "%d errors prohibited this %s from being saved".t(3,'penguin') => '3 errors prohibited this penguin from being saved'
      #
      #  * very basic pluralization of verb 'to be'
      #
      #   e.g. "There are %d translations to do".t(1) => 'There is 1 translation to do'
      #        "There are %d translations to do".t(3) => 'There are 3 translations to do'
      #
      #        "Are there %d penguins?".t(1) => 'Is there 1 penguin?'
      #        "Are there %d penguins?".t(3) => 'Are there 3 penguins?'

      def self.translate(string, args)
        return string unless args
        
        translated_string,string_interpolations, pluralization = nil
        
        case args
          when String
            translated_string = string % args
          when Fixnum
            pluralization = args
          when Array
            string_interpolations = args.select {|arg| arg.is_a? String}
            pluralization = args.detect {|arg| arg.is_a? Fixnum}
        end
       
       if pluralization
         
         #Handle singularization of verb 'to be'
         translated_string = string.gsub(/(are)\s+/,'is ') if pluralization == 1 && string.match(DOWN_CASE_VERBAL_PLURALIZATION_REGEXP)
         translated_string = string.gsub(/^(Are)\s+/,'Is ') if pluralization == 1 && string.match(UP_CASE_VERBAL_PLURALIZATION_REGEXP)
         
         #Handle plurals
         matches = translated_string ? translated_string.match(PLURALIZATION_REGEXP) : string.match(PLURALIZATION_REGEXP)
         pluralizable_string = matches[1] if matches
         plural = (pluralizable_string.gsub(/%d\s+/,'') % pluralization)
         plural = (pluralization == 1) ? Inflector.singularize(plural) : plural
         
         translated_string = if translated_string
             translated_string.gsub(PLURALIZATION_REGEXP, "#{pluralization} #{plural}")           
           else
             string.gsub(PLURALIZATION_REGEXP, "#{pluralization} #{plural}")             
           end
       end
       
       #Handle string interpolations
       translated_string = ((translated_string ? translated_string : string) % string_interpolations) unless string_interpolations.empty?
       translated_string ? translated_string : string
      end
    end
  end
end
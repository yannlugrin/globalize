module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module DateTime #:nodoc:
      # Define methods for handeling translation of strings.
      module Translation
        def t
          ActiveSupport::Translation::TranslatableDateTime.civil(self.year,self.mon, self.mday, self.hour, self.min, self.sec)
        end
      end
    end    
  end
end

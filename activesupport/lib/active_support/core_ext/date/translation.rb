module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Date #:nodoc:
      # Define methods for handeling translation of strings.
      module Translation
        def t
          ActiveSupport::Translation::TranslatableDate.new(self.year,self.mon, self.mday)
        end
      end
    end    
  end
end

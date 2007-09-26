module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Date #:nodoc:
      # Define methods for handeling translation of strings.
      module Translation
        def t(*args)
          ActiveSupport::Translation::TranslatableDate.translate(self, args)
        end
      end
    end    
  end
end

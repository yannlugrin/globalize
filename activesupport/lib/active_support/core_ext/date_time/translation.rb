module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module DateTime #:nodoc:
      # Define methods for handeling translation of strings.
      module Translation
        def t(*args)
          ActiveSupport::Translation::TranslatableDateTime.translate(self, args)
        end
      end
    end    
  end
end

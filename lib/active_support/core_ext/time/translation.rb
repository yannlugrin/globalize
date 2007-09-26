module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      # Define methods for handeling translation of strings.
      module Translation
        def t(*args)
          ActiveSupport::Translation::TranslatableTime.translate(self, args)
        end
      end
    end    
  end
end

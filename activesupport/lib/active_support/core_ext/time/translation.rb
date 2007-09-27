module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      # Define methods for handeling translation of times.
      module Translation
        def t
          ActiveSupport::Translation::TranslatableTime.at(self)
        end
      end
    end
  end
end

module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    class TranslatableDate < ::Date #:nodoc:
      def strftime(*args)
        super(*args)
      end
    end    
  end
end

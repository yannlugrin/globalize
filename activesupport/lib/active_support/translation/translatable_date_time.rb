module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    class TranslatableDateTime < ::DateTime #:nodoc:
      def strftime(*args)
        super(*args)
      end
    end
  end
end

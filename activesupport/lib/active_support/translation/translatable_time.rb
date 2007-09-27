module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    class TranslatableTime < ::Time#:nodoc:
      def strftime(*args)
        super(*args)
      end
    end
  end
end
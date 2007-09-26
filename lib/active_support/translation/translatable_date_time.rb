module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    module TranslatableDateTime #:nodoc:
      def self.translate(datetime, *args)
        datetime.strftime(args)
      end
    end
  end
end

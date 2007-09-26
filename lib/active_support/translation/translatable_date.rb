module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    module TranslatableDate #:nodoc:
      def self.translate(date, *args)
        date.strftime(args)
      end
    end    
  end
end

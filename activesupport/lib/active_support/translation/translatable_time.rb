module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    module TranslatableTime #:nodoc:
      def self.translate(time, *args)
        time.strftime(args)
      end
    end    
  end
end

module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    module TranslatableString #:nodoc:
      def self.translate(string, *args)
        args ? string % args : string
      end
    end    
  end
end

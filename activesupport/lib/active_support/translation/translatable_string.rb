module ActiveSupport #:nodoc:
  module Translation #:nodoc:
    module TranslatableString #:nodoc:
      def self.translate(string, *args)
        return string unless args
        if args.flatten.first.is_a? Integer
          string % args.flatten.first
        else
         string % args.flatten
        end
      end
    end    
  end
end

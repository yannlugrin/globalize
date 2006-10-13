module ActionView::Helpers::MultilingualRailsHelpers

  begin
    require 'money'
  rescue
    def money(*ignored)
      "Money gem not installed!"
    end
    return
  end

  def money(m, options = {})
    raise "Not a Money object: %s" % [m.inspect] unless m.kind_of?(Money)
    
    options[:local] ||= (m.currency == Locale.currency)
    options[:cents] ||= true
    m = m.exhange_to(options[:exhange_to]) if options[:exhange_to]
    
    case m.currency
      when 'USD', 'CAD', 'XCD', 'ARS', 'AUD', 'BSD', 'BBD', 'BZD', 'BMD', 'BRL', 'BND', 'KYD', 'CLP', 'COP', 'CUP', 'FJD', 'GYD', 'HKD', 'JMD', 'LRD', 'MXN', 'NAD', 'NZD', 'NIO', 'SGD', 'SBD', 'SRD', 'TWD', 'TOP', 'TTD', 'UYU', 'WST', 'ZWD'
        fmt = options[:local] ? "$!" : "$! %s"
      when 'SEK', 'NOK', 'DKK', 'EEK', 'ISK'
        fmt = options[:local] ? "! Kr" : "! %s"
      when 'EUR'
        fmt = "€!"
      when 'GBP', 'FKP', 'CYP', 'EGP', 'SHP', 'SYP', 'GIP'
        fmt = options[:local] ? "£!" : "£! %s"
      when 'YEN'
        fmt = "¥!"
      else
        fmt = "! %s"
    end
    
    return ( options[:cents] ? fmt.gsub('!','%.02f') : fmt.gsub('!','%d') ) % [m.cents*100, m.currency]
  end

end

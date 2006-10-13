module Multilingual
  class Currency
    include Comparable

    attr_reader :cents

    class CurrencyError < StandardError# :nodoc:
    end

    def initialize(new_cents)
      @cents = new_cents.nil? ? nil : new_cents.to_i
    end

    @@free = Currency.new(0)
    @@free.freeze

    def self.free
      @@free
    end

    @@na = Currency.new(nil)
    @@na.freeze

    def self.na
      @@na
    end

    def dollar_part
      na? ? nil : cents / 100
    end

    def cent_part
      na? ? nil : cents % 100
    end

    def <=>(other)
      if other.respond_to? :cents
        if na?
          other.na? ? 0 : 1
        else
          other.na? ? -1 : cents <=> other.cents
        end
      elsif other.kind_of? Integer
        na? ? 1 : cents <=> other
      else
        raise "can only compare with money or integer"
      end      
    end

    def +(other_money)
      (na? || other_money.na?) ? Currency.na :
        Currency.new(cents + other_money.cents)
    end

    def -(other_money)
      (na? || other_money.na?) ? Currency.na :
        Currency.new(cents - other_money.cents)
    end

    # get the cents value of the object
    def cents
      @cents
    end

    # multiply money by amount
    def *(amount)
      return Currency.new(nil) if na?
      new_cents = amount * cents;
      new_cents = new_cents.round if new_cents.respond_to? :round
      Currency.new(new_cents)
    end

    # divide money by amount
    def /(amount)
      return Currency.new(nil) if na?
      new_cents = cents / amount;
      new_cents = new_cents.round if new_cents.respond_to? :round
      Currency.new(new_cents)
    end

    def format(options = {})
      return :no_price_available.t("call for price") if na?

      if options[:code]
        currency_code = options[:country] ? 
          options[:country].currency_code : Locale.active.currency_code
        self.amount + " " + currency_code
      else
        fmt = Locale.active.currency_format
        fmt.sub('%n', self.amount)
      end
    end

    def amount
      return nil if na?
      dollar_part.to_s + Locale.active.decimal_sep + 
        sprintf("%02d", cent_part)
    end

    def to_s
      self.format
    end

    def self.parse(num)
      case
      when num.is_a?(String)
        raise ArgumentError, "Not an amount (#{num})" if num.delete("^0-9").empty?
        _dollars, _cents = num.delete("^0-9.").split('.', 2)
        _cents = 0 if !_cents
        Currency.new(_dollars.to_i * 100 + _cents.to_i)
      when num.is_a?(Numeric)
        Currency.new(num * 100)
      when num.is_a?(NilClass)
        Currency.na
      else
        raise ArgumentError, "Unrecognized object #{num.class.name} for Currency"
      end
    end

    # Conversion to self
    def to_currency
      self
    end

    def empty?
      cents == 0
    end

    def na?
      cents.nil?
    end

  end
end
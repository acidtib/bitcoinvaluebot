module BVB::Services
  class Money
    class InvalidAmount < Exception
    end

    def self.new(amount)
      format(clean_init_amount(amount))
    end

    def self.format(amount)
      currency_symbol = "$"
      decimal_mark = "."
      subunit_shift = Math.log(100, 10).to_i
      amount_str = amount.to_s
      unit_str = amount_str[0, amount_str.size - subunit_shift]
      subunit_str = amount_str[amount_str.size - subunit_shift, amount_str.size]
      pre_formatted_value = "#{unit_str}#{decimal_mark}#{subunit_str}"
      currency_symbol + pre_formatted_value.to_f.format(decimal_places: 2).to_s
    end

    protected def self.clean_init_amount(amount)
      case amount
      when Int32
        amount
      when Float64
        (amount * 100).to_i32
      when String
        if amount.to_i?
          amount.to_i32
        elsif amount.to_f?
          self.clean_init_amount(amount.to_f64)
        else
          raise InvalidAmount.new("String doesn't contain valid amount")
        end
      else
        raise InvalidAmount.new
      end
    end
  end
end
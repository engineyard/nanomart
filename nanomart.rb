# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    $prompter = prompter
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    itm = [Vodka, Beer, Whiskey, Cigarettes, Cola, CannedHaggis].detect do |product|
            product.name == itm_type
          end
    itm.restrictions.each do |r|
      itm.try_purchase(r.ck)
    end
    itm.log_sale
  end
end

# class HighlinePrompter
#   def get_age
#     HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
#   end
# end

class Product
  attr_accessor :name, :restrictions

  def initialize(name, restrictions)
    @name, @restrictions = name, restrictions
  end
  def want_to_buy(logfile, prompter)
    @logfile, @prompter = logfile, prompter
    self
  end
  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end
  def log_sale(*args)
    #don't care
  end
end

class GreatRestriction
  def ck
    sellable?($prompter)
  end
end

class AgeRestriction < GreatRestriction
  def initialize(age)
    @age = age
  end
  def sellable?(customer)
    customer.get_age >= @age
  end
end

class DayRestriction < GreatRestriction
  def initialize(day)
    @day = day
  end
  def sellable?(customer)
    !Time.now.send("#{@day}?")
  end
end

Vodka = Product.new(:vodka, [AgeRestriction.new(21), DayRestriction.new(:sunday)])
Beer = Product.new(:beer, [AgeRestriction.new(21)])
Whiskey = Product.new(:whiskey, [AgeRestriction.new(21), DayRestriction.new(:sunday)])
Cigarettes = Product.new(:cigarettes, [AgeRestriction.new(18)])
Cola = Product.new(:cola, [])
CannedHaggis = Product.new(:cannedhaggis, [])

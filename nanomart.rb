# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  INVENTORY_LOG = 'inventory.log'
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
    @products = {
      :beer => Beer.new,
      :whiskey => Whiskey.new,
      :cigarettes => Cigarettes.new,
      :cola => Cola.new,
      :canned_haggis => CannedHaggis.new
    }
  end

  def sell_me(itm_type)
    unless @products.key?(itm_type)
      raise ArgumentError, "Don't know how to sell #{itm_type}"
    end

    itm = @products[itm_type]
    itm.rstrctns.each do |r|
      r.ck(@prompter)
    end
    log_sale(itm.name)
  end

  def log_sale(product)
    File.open(@logfile, 'a') do |f|
      f.write(product.to_s + "\n")
    end
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class Age
    def initialize(age)
      @age = age
    end

    def ck(prompter)
      raise Nanomart::NoSale unless prompter.get_age >= @age
    end
  end

  class DrinkingAge < Age
    def initialize
      super(DRINKING_AGE)
    end
  end

  class SmokingAge < Age
    def initialize
      super(SMOKING_AGE)
    end
  end

  class SundayBlueLaw
    def ck(promper)
      # pp Time.now.wday
      # debugger
      raise Nanomart::NoSale unless Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item

  def name
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def rstrctns
    []
  end
end

class Beer < Item
  def rstrctns
    [Restriction::DrinkingAge.new]
  end
end

class Whiskey < Item
  # you can't sell hard liquor on Sundays for some reason
  def rstrctns
    [Restriction::DrinkingAge.new, Restriction::SundayBlueLaw.new]
  end
end

class Cigarettes < Item
  # you have to be of a certain age to buy tobacco
  def rstrctns
    [Restriction::SmokingAge.new]
  end
end

class Cola < Item
end

class CannedHaggis < Item
  # the common-case implementation of Item.nam doesn't work here
  def nam
    :canned_haggis
  end
end



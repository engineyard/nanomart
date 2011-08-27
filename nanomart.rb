# you can buy just a few things at this nanomart
require 'highline'

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


module Restriction
  
  class Age
    def initialize(p)
      @prompter = p
    end
      
    def ck
      if @prompter.get_age >= @restriction_age
        true
      else
        false
      end
    end
  end

  class DrinkingAge < Age
    def initialize(p)
      @restriction_age = 21
      super
    end
  end

  class SmokingAge < Age
    def initialize(p)
      @restriction_age = 18
      super
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def ck
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter, name)
    @logfile, @prompter = logfile, prompter
    @name = name.to_s
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(nam.to_s + "\n")
    end
  end

  def nam
    @name
  end

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  class Beer < Item
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [Restriction::SmokingAge.new(@prompter)]
    end
  end
  
  class UnrestrictedItem < Item
    def rstrctns
      []
    end
  end

  class Cola < UnrestrictedItem
  end

  class CannedHaggis < UnrestrictedItem
  end
end

class Nanomart
  SELLABLE_ITEMS = {
    :beer => Item::Beer,
    :whiskey => Item::Whiskey,
    :cigarettes => Item::Cigarettes,
    :cola => Item::Cola,
    :canned_haggis => Item::CannedHaggis
  }
    
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    if SELLABLE_ITEMS.keys.include?(itm_type)
      itm = SELLABLE_ITEMS[itm_type].new(@logfile, @prompter, itm_type)
    else
      raise ArgumentError, "Don't know how to sell #{itm_type}"
    end
        
    itm.rstrctns.each do |r|
      itm.try_purchase(r.ck)
    end
    itm.log_sale
  end
end
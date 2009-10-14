# you can buy just a few things at this nanomart
require 'highline'

class NoSale < StandardError; end

def process_transaction_for(itm_type)
  itm = case itm_type
         when :beer
           Item::Beer.new
         when :whiskey
           Item::Whiskey.new
         when :cigarettes
           Item::Cigarettes.new
         when :cola
           Item::Cola.new
         when :canned_haggis
           Item::CannedHaggis.new
         else
           raise ArgumentError, "Don't know how to sell #{itm_type}"
         end

  itm.rstrctns.each do |r|
    r.ck or raise NoSale
  end
  itm.log_sale
end

module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def ck
      age = HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
      if age >= DRINKING_AGE
        true
      else
        false
      end
    end
  end

  class SmokingAge
    def ck
      age = HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
      if age >= SMOKING_AGE
        true
      else
        false
      end
    end
  end

  class SundayBlueLaw
    def ck
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def log_sale
    File.open(INVENTORY_LOG, 'a') do |f|
      f.write(nam.to_s + "\n")
    end
  end

  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
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
    def rstrctns
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end

    def rstrctns
      []
    end
  end
end


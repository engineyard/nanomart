# you can buy just a few things at this nanomart
require 'highline'

class NoSale < StandardError; end

def process_transaction_for(item_type)
  item = case item_type
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
           raise ArgumentError, "Don't know how to sell #{item_type}"
         end

  item.restrictions.each do |r|
    r.check or raise NoSale
  end
  item.log_sale
end

module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def check
      age = HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
      if age >= DRINKING_AGE
        true
      else
        false
      end
    end
  end

  class SmokingAge
    def check
      age = HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
      if age >= SMOKING_AGE
        true
      else
        false
      end
    end
  end

  class SundayBlueLaw
    def check
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def log_sale
    File.open(INVENTORY_LOG, 'a') do |f|
      f.write(name.to_s + "\n")
    end
  end

  def restrictions
    []
  end

  def name
    self.class.to_s.sub(/^Item::/, '').downcase.to_sym
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge.new]
    end
  end

  class Whiskey < Item
    def restrictions
      # you can't sell hard liquor on Sundays for some reason
      [Restriction::DrinkingAge.new(DRINKING_AGE), Restriction::SundayBlueLaw.new]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new]
    end
  end

  class Cola < Item; end

  class CannedHaggis < Item
    # the common-case implementation of Item.name doesn't work here
    def name
      :canned_haggis
    end
  end
end


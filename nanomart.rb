# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile)
    @logfile = logfile
  end

  def sell_me(item_type)
    item = case item_type
          when :beer
            Item::Beer.new(@logfile)
          when :whiskey
            Item::Whiskey.new(@logfile)
          when :cigarettes
            Item::Cigarettes.new(@logfile)
          when :cola
            Item::Cola.new(@logfile)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile)
          else
            raise ArgumentError, "Don't know how to sell #{item_type}"
          end

    item.restrictions.each do |r|
      item.try_purchase(r.check)
    end
    item.log_sale
  end
end

class HighlinePrompter
  def self.get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def check
      age = HighlinePrompter.get_age
      age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def check
      age = HighlinePrompter.get_age
      age >= SMOKING_AGE
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

  def initialize(logfile)
    @logfile = logfile
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(nam.to_s + "\n")
    end
  end

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  def restrictions
    []
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge.new]
    end

    def nam
      :beer
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge.new, Restriction::SundayBlueLaw.new]
    end

    def nam
      :whiskey
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new]
    end

    def nam
      :cigarettes
    end
  end

  class Cola < Item
    def nam
      :cola
    end
  end

  class CannedHaggis < Item
    def nam
      :canned_haggis
    end
  end
end


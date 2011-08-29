# you can buy just a few things at this nanomart
require 'highline'


class Log
  def self.log(message, file)
    File.open(file, 'a') do |f|
      f.puts message
    end
  end

  def self.log_purchase(product, file=nil)
    file ||= logfile
    log("Purchased #{product.name.to_s}", file)
  end

  def self.logfile=(file)
    @file = file
  end

  def self.logfile
    @file
  end
end

class Nanomart
  class NoSale < StandardError; end

  def sell_me(item_type)
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

    item.try_purchase
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
  def try_purchase
    restrictions.each do |r|
      raise Nanomart::NoSale unless r.check
    end
    Log.log_purchase(self)
    true
  end

  def restrictions
    []
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge.new]
    end

    def name
      :beer
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge.new, Restriction::SundayBlueLaw.new]
    end

    def name
      :whiskey
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new]
    end

    def name
      :cigarettes
    end
  end

  class Cola < Item
    def name
      :cola
    end
  end

  class CannedHaggis < Item
    def name
      :canned_haggis
    end
  end
end


# you can buy just a few things at this nanomart

class Nanomart
  def sell_me(itm_type, age)
    item = case itm_type
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

    item.try_purchase(age)

    Logger.log_sale(item)
  end
end

module Restriction
  class DrinkingAge
    DRINKING_AGE = 21

    def self.check(age)
      age >= DRINKING_AGE
    end
  end

  class SmokingAge
    SMOKING_AGE = 18

    def self.check(age)
      age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def self.check(age)
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Logger
  def self.log_sale(object)
    STDOUT.puts(object.class.name)
  end
end

class Item
  class NoSale < StandardError
  end

  def try_purchase(age)
    self.restrictions.each do |r|
      if !r.check(age)
        raise NoSale
      end
    end
    true
  end

  def restrictions
    []
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge, Restriction::SundayBlueLaw]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge]
    end
  end

  class Cola < Item
  end

  class CannedHaggis < Item
  end
end

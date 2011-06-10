# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    itm = case itm_type
          when :beer
            Item::Beer.new()
          when :whiskey
            Item::Whiskey.new()
          when :cigarettes
            Item::Cigarettes.new()
          when :cola
            Item::Cola.new()
          when :canned_haggis
            Item::CannedHaggis.new()
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    age = @prompter.get_age

    itm.rstrctns.each do |r|
      itm.try_purchase(r.ck(age))
    end

    File.open(@logfile, 'a') do |f|
      f.write(itm_type.to_s + "\n")
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

  class DrinkingAge
    def ck(age)
      if age >= DRINKING_AGE
        true
      else
        false
      end
    end
  end

  class SmokingAge
    def ck(age)
      if age >= SMOKING_AGE
        true
      else
        false
      end
    end
  end

  class SundayBlueLaw
    def ck(age)
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  def rstrctns
    []
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
    # the common-case implementation of Item.name doesn't work here
    def name
      :canned_haggis
    end
  end
end


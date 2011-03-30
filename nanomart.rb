# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)
    item_types = [Beer, Whiskey, Cigarettes, Cola, CannedHaggis]
    
    if item_types.include? item_type
      item = item_type.new(@logfile, @prompter)
    else
      raise ArgumentError, "Don't know how to sell #{item_type}"
    end

    item.rstrctns.each do |r|
      item.try_purchase(r.ck)
    end
    item.log_sale
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
  
  class Restrictions
    def initialize(p)
      @prompter = p
    end
    
  end

  class DrinkingAge < Restrictions
    def ck
      age = @prompter.get_age
      if age >= DRINKING_AGE
        true
      else
        false
      end
    end
  end

  class SmokingAge< Restrictions
    def initialize(p)
      @prompter = p
    end

    def ck
      age = @prompter.get_age
      if age >= SMOKING_AGE
        true
      else
        false
      end
    end
  end

  class SundayBlueLaw < Restrictions

    def ck
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(self.class.to_s + "\n")
    end
  end


  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
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

class Cola < Item
  def rstrctns
    []
  end
end

class CannedHaggis < Item
  def rstrctns
    []
  end
end


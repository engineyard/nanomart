# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
    
    @registry = {}
    @registry[:beer] = Item::Beer;
    @registry[:whiskey] = Item::Whiskey;
    @registry[:cigarettes] = Item::Cigarettes;
    @registry[:cola] = Item::Cola;
    @registry[:canned_haggis] = Item::CannedHaggis;
      
  end

  def sell_me(item_type)
    
    if @registry.has_key?(item_type)
      item = @registry[item_type].new(@prompter)
    else
      raise ArgumentError, "Don't know how to sell #{type}"
    end
    
    item.restrictions.each do |r|
      if !r.check
        raise NoSale
      end
    end
    
    log_sale(item_type, item)
  end
  
  def log_sale(name, item)
    File.open(@logfile, 'a') do |f|
      f.write(name.to_s + "\n")
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
    def initialize(p)
      @prompter = p
    end

    def check
      age = @prompter.get_age
      age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def initialize(p)
      @prompter = p
    end

    def check
      age = @prompter.get_age
      age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def check
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  
  def initialize(prompter)
    @prompter = prompter
  end

  class Beer < Item
    
    def restrictions
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new(@prompter)]
    end
  end

  class Cola < Item
    
    def restrictions
      []
    end
  end

  class CannedHaggis < Item
    
    def restrictions
      []
    end
  end
end


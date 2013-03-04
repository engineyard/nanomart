# you can buy just a few things at this nanomart
require 'highline'


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

    def purchase_allowed?
      if @prompter.get_age >= DRINKING_AGE
        true
      else
        false
      end
    end
  end

  class SmokingAge
    def initialize(p)
      @prompter = p
    end

    def purchase_allowed?
      age = @prompter.get_age
      if age >= SMOKING_AGE
        true
      else
        false
      end
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def purchase_allowed?
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
      f.write(self.class.name.to_s + "\n")
    end
  end

  def self.name
    class_string = self.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase
    restrictions.each do | r |
       if not r.purchase_allowed?
           raise Nanomart::NoSale       
       end
    end
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
    def self.name
    	:canned_haggis
    end

    def restrictions
      []
    end
  end
end

class Nanomart
  class NoSale < StandardError; end

  ITEM_CLASSES = [Item::Beer, Item::Whiskey, Item::Cigarettes, Item::Cola, Item::CannedHaggis]

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)
    item_class = ITEM_CLASSES.detect do | item_class | 
        item_class.name == item_type
    end
    item = item_class.new(@logfile, @prompter)

    item.try_purchase

    item.log_sale
  end
end




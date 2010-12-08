# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    
    store_items = { :beer => Item::Beer, :whiskey => Item::Whiskey, :cigarettes => Item::Cigarettes, :cola => Item::Cola, :canned_haggis => Item::CannedHaggis }
    
    itm = store_items[itm_type].new(@logfile, @prompter) or raise ArgumentError, "Don't know how to sell #{itm_type}"

    itm.restrictions.each do |r|
      itm.try_purchase(r.can_buy)
    end
    itm.log_sale
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

    def can_buy
       @prompter.get_age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def initialize(p)
      @prompter = p
    end

    def can_buy
      @prompter.get_age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def can_buy
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
      f.write(class_name_for_log + "\n")
    end
  end

  def class_name_for_log
    self.class.to_s.sub(/^Item::/, '').downcase
  end

  def try_purchase(success)
    success or raise Nanomart::NoSale
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
    # the common-case implementation of Item.nam doesn't work here
    def class_name_for_log
      'canned_haggis'
    end

    def restrictions
      []
    end
  end
end


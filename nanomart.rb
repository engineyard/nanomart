# you can buy just a few things at this nanomart
require 'highline'
require 'active_support/inflector'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)
    itm = begin
      "Item::#{item_type.to_s.camelize}".constantize.new(@logfile, @prompter)
    rescue NameError
      raise ArgumentError, "Don't know how to sell #{item_type}"
    end
    
    itm.try_purchase
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
    def check(prompter)
      prompter.get_age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def check(prompter)
      prompter.get_age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def check(prompter)
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
      f.write(name.to_s + "\n")
    end
  end

  def name
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase
    restrictions.all? {|r| r.check(@prompter)} or
      raise Nanomart::NoSale
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge.new]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::SundayBlueLaw.new, Restriction::DrinkingAge.new]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new]
    end
  end

  class Cola < Item
    def restrictions
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.name doesn't work here
    def name
      :canned_haggis
    end

    def restrictions
      []
    end
  end
end


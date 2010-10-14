# you can buy just a few things at this nanomart
require 'rubygems'
require 'bundler'
Bundler.setup

require 'highline'
require 'logger'
require 'active_support/core_ext/string/inflections'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @log, @prompter = Logger.new(logfile), prompter
  end
  
  def log_sale(item)
    @log.info("#{item.name} sold")
  end

  def sell_me(item_type)
    class_name = item_type.to_s.classify
    item       = "Item::#{class_name}".constantize
    item       = item.new(@prompter)
    
    item.try_purchase
    log_sale(item)
  rescue NameError
    raise ArgumentError, "Don't know how to sell #{item_type}"
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer)
  end
end


module Restriction
  class Age
    def initialize(p)
      @prompter = p
    end

    def check
      @prompter.get_age >= Age::AGE_LIMIT
    end
  end

  class DrinkingAge < Age
    Age::AGE_LIMIT = 21
  end

  class SmokingAge < Age
    Age::AGE_LIMIT = 18
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def check
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(prompter)
    @prompter = prompter
  end
  
  def name
    class_string       = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym          = lower_class_string.to_sym
    class_sym
  end

  def try_purchase
    restrictions.each do |restriction|
      raise Nanomart::NoSale unless restriction.check
    end
    
    true
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
    # the common-case implementation of Item.name doesn't work here
    def name
      :canned_haggis
    end

    def restrictions
      []
    end
  end
end


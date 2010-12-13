# you can buy just a few things at this nanomart
require 'highline'

class Loggger
  class << self
   def set_file(file)
     @logfile = file
   end
   def filename 
     @logfile || 'default.log'
   end
   def log
    File.open(filename, 'a') do |f|
      f.write(yield.to_s + "\n")
    end
   end
  end
end

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    Loggger.set_file(logfile)
    @prompter = prompter
  end

  def sell_me(item_type)
    item = Item.build(item_type,@prompter)
    item.purchase
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
  Drinking = lambda {|p|
    p.get_age >= DRINKING_AGE
  }
  Smoking = lambda {|p|
    p.get_age >= SMOKING_AGE
  }
  SundayBlueLaw = lambda {|p|
    Time.now.wday != 0      # 0 is Sunday
  }
end

class Item
  INVENTORY_LOG = 'inventory.log'
  class << self
    def build(nam,prompter)
      nam_to_class(nam).new(prompter)
    end

    def nam_to_class(nam)
      const = nam.to_s.split('_').collect(&:capitalize).join('')
      is_klass = const_defined?(const)
      if is_klass
        klass = const_get(const)
      else
        raise ArgumentError, "Don't know how to sell #{nam}"
      end
      klass
    end
  end

  def initialize(prompter)
    @prompter =  prompter
  end

  def log_sale
    Loggger.log do 
      nam.to_s 
    end
  end

  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def purchase
    purchased = try_purchase()
    self.log_sale if purchased
  end

  private 
  def try_purchase()
    success = self.restrictions.all? do |lamb|
      lamb.call(@prompter)
    end
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  class Beer < Item
    def restrictions
      [Restriction::Drinking]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::Drinking, Restriction::SundayBlueLaw]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::Smoking]
    end
  end

  class Cola < Item
    def restrictions
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end

    def restrictions
      []
    end
  end
end


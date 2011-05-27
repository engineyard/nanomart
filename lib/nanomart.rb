# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  class Inventory
    def initialize
      @inventory = {}
    end
    
    def add(item)
      @inventory[item.name] = item
    end
    
    def [](item_type)
      @inventory[item_type]
    end
  end
  
  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
    
    @inventory = Inventory.new
    @inventory.add Item.new(:beer).with_restrictions(:drinking_age)
    @inventory.add Item.new(:whiskey).with_restrictions(:drinking_age, :sunday_blue_law)
    @inventory.add Item.new(:cigarettes).with_restrictions(:smoking_age)
    @inventory.add Item.new(:cola)
    @inventory.add Item.new(:canned_haggis)
  end

  def sell_me(item_type)
    item = @inventory[item_type]
    raise ArgumentError, "Don't know how to sell #{item_type}" unless item

    item.restrictions.each do |r|
      raise Nanomart::NoSale unless r.check(@prompter)
    end
    log_sale item
    
    item
  end
  
  def log_sale(item)
    File.open(@logfile, 'a') do |f|
      f.write(item.name.to_s + "\n")
    end
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


module Restriction
  class AgeRestriction
    def initialize(age)
      @age = age
    end
    
    def check(prompter)
      prompter.get_age >= @age
    end
  end
  
  class DrinkingAge < AgeRestriction
    DRINKING_AGE = 21
    
    def initialize
      super DRINKING_AGE
    end
  end

  class SmokingAge < AgeRestriction
    SMOKING_AGE = 18
    
    def initialize
      super SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def check(prompter)
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  attr_reader :name, :restrictions
  
  def initialize(name)
    @name = name
    @restrictions = []
  end
  
  def with_restrictions(*restrictions)
    restrictions.each do |restriction|
      klass = restriction.to_s.split('_').map { |s| s.capitalize }.join
      @restrictions << Restriction.const_get(klass).new
    end
    self
  end
end


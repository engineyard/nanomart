# you can buy just a few things at this nanomart
require 'highline'

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


module Restriction
  class MinimumAge
    def initialize(minimum_age, prompter)
    	@minimum_age = minimum_age
	@prompter = prompter	
    end
    
    def purchase_allowed?
      # Consider making this throw a Nanomart::NoSale instead of returning a boolean
      @prompter.get_age >= @minimum_age
    end
  end 

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def purchase_allowed?
      not Time.now.sunday?
    end
  end
end

class Item
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  def initialize(logfile, prompter)
    # logfile and prompter shouldn't be passed into the items
    @logfile, @prompter = logfile, prompter
  end

  def restrictions
    []
  end

  def log_sale
    # logging responsibility should not be on item instances
    File.open(@logfile, 'a') do |f|
      f.write(self.class.name.to_s + "\n")
    end
  end

  def self.name
    self.to_s.sub(/^Item::/, '').downcase.to_sym
  end

  def try_purchase
    restrictions.each do | r |
       if not r.purchase_allowed?
           raise Nanomart::NoSale       
       end
    end
  end

  class Beer < Item
     # Consider making an Alcohol item to consolidate instantiation of DRINKING_AGE restriction
     def restrictions
      [Restriction::MinimumAge.new(DRINKING_AGE, @prompter)]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason

    def restrictions
      [Restriction::MinimumAge.new(DRINKING_AGE, @prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco

    def restrictions
      [Restriction::MinimumAge.new(SMOKING_AGE, @prompter)]
    end
  end

  class Cola < Item
  end

  class CannedHaggis < Item
    def self.name
    	:canned_haggis
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
    # Move this block to a method
    item_class = ITEM_CLASSES.detect do | item_class | 
        item_class.name == item_type
    end
    item = item_class.new(@logfile, @prompter)

    item.try_purchase

    item.log_sale
  end
end




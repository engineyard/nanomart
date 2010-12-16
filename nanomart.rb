# you can buy just a few things at this nanomart  

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)
    item = Item.new(@logfile, @prompter, item_type)
    
    item.restrictions.each do |r|
      item.try_purchase(r.age_check)
    end
    item.log_sale
  end
end

module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def initialize(p)
      @prompter = p
    end

    def age_check
      age = @prompter.get_age
      if age >= DRINKING_AGE
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

    def age_check
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

    def age_check
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  
  ItemRestrictions = {
    :cola => [],
    :canned_haggis => [],
    :cigarettes  => [Restriction::SmokingAge],
    :beer    => [Restriction::DrinkingAge],
    :whiskey => [Restriction::DrinkingAge, Restriction::SundayBlueLaw],
    :whiskey_cigarettes => [Restriction::SmokingAge, Restriction::SundayBlueLaw]
  }
  
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter, item_type)
    @logfile, @prompter = logfile, prompter
    @item_type = item_type
  end

  def restrictions
    ItemRestrictions[@item_type].each.map do |klass|
      klass.new(@prompter)
    end
  end
  
  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(@item_type.to_s + "\n")
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


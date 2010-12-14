# you can buy just a few things at this nanomart
require 'highline'

module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def initialize(p)
      @prompter = p
    end

    def check_conditions
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

    def check_conditions
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

    def check_conditions
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Nanomart
  INVENTORY = {
    :beer => [Restriction::DrinkingAge],
    :whiskey => [Restriction::DrinkingAge, Restriction::SundayBlueLaw],
    :cigarettes => [Restriction::SmokingAge],
    :canned_haggis => [],
    :cola => []
  }

  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)
    raise NoSale, "Don't know how to sell #{item_type}" unless INVENTORY.has_key? item_type
    item = Item.new(item_type, @logfile, @prompter)

    item.restrictions.each do |r|
      item.try_purchase(r.check_conditions)
    end
    item.log_sale
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end



class Item
  def initialize(type, logfile, prompter)
    @type, @logfile, @prompter = type, logfile, prompter
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(name.to_s + "\n")
    end
  end

  def name
    self.class.to_s.sub(/^Item::/, '').downcase.to_sym
  end

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  def restrictions
    Nanomart::INVENTORY[@type].map do |restriction|
      restriction.new(@prompter)
    end
  end
end


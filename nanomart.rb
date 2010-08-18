# you can buy just a few things at this nanomart
require 'highline'

class Nanomart
  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_class)
    item_class.new(@logfile, @prompter).purchase!
  end
end

class HighlinePrompter
  def age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end

class Restriction
  def initialize(prompter)
    @prompter = prompter
  end

  class DrinkingAge < Restriction
    def ok?
      @prompter.age >= 21
    end
  end

  class SmokingAge < Restriction
    def ok?
      @prompter.age >= 18
    end
  end

  class SundayBlueLaw < Restriction
    def ok?
      sunday = 0
      Time.now.wday != sunday
    end
  end
end

class Item
  class NoSale < StandardError; end
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def restrictions
    []
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(name + "\n")
    end
  end

  def name
    self.class.to_s.downcase
  end

  def purchase!
    restrictions.each do |restriction|
      raise Item::NoSale unless restriction.ok?
    end
    log_sale
  end
end

class Beer < Item
  def restrictions
    [Restriction::DrinkingAge.new(@prompter)]
  end
end

class Whiskey < Item
  def restrictions
    [Restriction::DrinkingAge.new(@prompter), 
     Restriction::SundayBlueLaw.new(@prompter)]
  end
end

class Cigarettes < Item
  def restrictions
    [Restriction::SmokingAge.new(@prompter)]
  end
end

class Cola < Item
end

class CannedHaggis < Item
end


# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_class)
    item = item_class.new(@logfile, @prompter)
    begin
      item.rstrctns.each do |r|
        item.try_purchase(r.check_age)
      end
      item.log_sale
    rescue Nanomart::NoSale
      item.log_no_sale
      raise Nanomart::NoSale
    end
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


module Restriction
  class Base
    DRINKING_AGE = 21
    SMOKING_AGE = 18
  
    def initialize(p)
      @prompter = p
    end
  end
end

class DrinkingAge < Restriction::Base
  def check_age
    @prompter.get_age >= DRINKING_AGE
  end
end

class SmokingAge < Restriction::Base
  def check_age
    @prompter.get_age >= SMOKING_AGE
  end
end

class SundayBlueLaw < Restriction::Base
  def check_age
    Time.now.wday != 0      # 0 is Sunday
  end
end


class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write("Sold #{nam} to person of age #{@prompter.get_age}\n")
    end
  end
  
  def log_no_sale
    File.open(@logfile, 'a') do |f|
      f.write("Refused to #{nam} to person of age #{@prompter.get_age}\n")
    end
  end

  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase(success)
    success ? true : raise (Nanomart::NoSale)
  end

  class Beer < Item
    def rstrctns
      [DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [DrinkingAge.new(@prompter), SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [SmokingAge.new(@prompter)]
    end
  end

  class Cola < Item
    def rstrctns
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end

    def rstrctns
      []
    end
  end
end


# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile)
    @logfile = logfile
  end

  def sell_me(person, itm_type)
    itm = case itm_type
          when :beer
            Item::Beer.new()
          when :whiskey
            Item::Whiskey.new()
          when :cigarettes
            Item::Cigarettes.new()
          when :cola
            Item::Cola.new()
          when :canned_haggis
            Item::CannedHaggis.new()
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    # itm.rstrctns.each do |r|
    #       itm.try_purchase(r.ck)
    #     end
    purchase = Purchase.new
    purchase.sell_item(person, itm)
  end
end

class Person
  attr_accessor :age
end

class Purchase
  def sell_item(person, item)
    item.rstrctns.each do |r|
      if r.ck(person)
        #item.log_sale
      else
        raise Nanomart::NoSale
      end
    end 
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
    def initialize()
    end

    def ck(person)
      #age = @person
      if person.age >= DRINKING_AGE
        true
      else
        false
      end
    end
  end

  class SmokingAge
    def initialize()
    end

    def ck(person)
      #age = @prompter
      if person.age >= SMOKING_AGE
        true
      else
        false
      end
    end
  end

  class SundayBlueLaw
    def initialize()
    end

    def ck (person)
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize()
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(nam.to_s + "\n")
    end
  end

  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase(person)
    if person.age <= self.rest
    end
    # if success
    #       return true
    #     else
    #       raise Nanomart::NoSale
    #     end
  end

  class Beer < Item
    def rstrctns
      [Restriction::DrinkingAge.new()]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [Restriction::DrinkingAge.new(), Restriction::SundayBlueLaw.new()]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [Restriction::SmokingAge.new()]
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


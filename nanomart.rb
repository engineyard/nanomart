# you can buy just a few things at this nanomart
Bundler.require

class Nanomart
  def self.run(logfile)
    new(logfile, Person.new).run
  end

  class NoSale < StandardError; end

  def initialize(logfile, person)
    @logfile, @person = logfile, person
  end

  def run
    item_type = @person.get_item
    sell_me(item_type.to_sym)
  end

  def sell_me(item_type)
    itm = case item_type
          when :beer
            Item::Beer.new(@logfile)
          when :whiskey
            Item::Whiskey.new(@logfile)
          when :cigarettes
            Item::Cigarettes.new(@logfile)
          when :cola
            Item::Cola.new(@logfile)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile)
          else
            raise ArgumentError, "Don't know how to sell #{item_type}"
          end

    itm.try_purchase(@person)
    itm.log_sale
  end
end

class Person
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end

  def get_item
    HighLine.new.ask('Item? ', String)
  end
end


module Restriction
  class DrinkingAge
    def check(person)
      person.get_age >= 21
    end
  end

  class SmokingAge
    def check(person)
      person.get_age >= 18
    end
  end

  class SundayBlueLaw
    def check(person)
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  def initialize(logfile)
    @logfile = logfile
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
    restrictions.each do |r|
      unless r.check(person)
        raise Nanomart::NoSale
      end
    end
    true
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge.new]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge.new, Restriction::SundayBlueLaw.new]
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
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end

    def restrictions
      []
    end
  end
end


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
    if itm = item_named(item_type)
      if itm.try_purchase(@person)
        @person.take_item(itm)

        File.open(@logfile, 'a') do |f|
          f.write(itm.name.to_s + "\n")
        end
      end
    else
      @person.unknown_item(item_type)
    end
  end

  def item_named(name)
    items.find do |item|
      item.name == name
    end
  end

  def items
    [
      Item.new(:beer,          [Restriction::DrinkingAge.new]),
      # you can't sell hard liquor on Sundays for some reason
      Item.new(:whiskey,       [Restriction::DrinkingAge.new, Restriction::SundayBlueLaw.new]),
      # you have to be of a certain age to buy tobacco
      Item.new(:cigarettes,    [Restriction::SmokingAge.new]),
      Item.new(:cola,          []),
      Item.new(:canned_haggis, [])
    ]
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
  def initialize(name, restrictions)
    @name         = name
    @restrictions = restrictions
  end
  attr_reader :name

  def try_purchase(person)
    @restrictions.each do |r|
      unless r.check(person)
        return false
      end
    end
    true
  end
end

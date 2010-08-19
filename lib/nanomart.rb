# you can buy just a few things at this nanomart
Bundler.require

class Nanomart
  def self.run(logfile, person = Person.new)
    new(logfile, person).run
  end

  def initialize(logfile, person)
    @logfile, @person = logfile, person
  end

  def run
    while item_type = @person.next_item(item_names)
      sell_me(item_type)
    end
  end

  def sell_me(item_type)
    if itm = item_named(item_type)
      if itm.try_purchase(@person)
        @person.take_item(item_type)

        File.open(@logfile, 'a') do |f|
          f.write(itm.name.to_s + "\n")
        end
      else
        @person.disallowed_item(item_type)
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

  def item_names
    items.map do |item|
      item.name
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
  # prompts for user's age, reads it in
  def get_age
    @age ||= HighLine.new.ask('Age? ', Integer)
  end

  def next_item(names)
    HighLine.new.choose do |c|
      c.prompt = 'Item? '

      names.each do |name|
        c.choice(name) { return name }
      end
      c.choice("Leave the mart") { exit }
    end
  end

  def take_item(name)
    puts "Here you go, have some #{name}"
  end

  def disallowed_item(name)
    puts "Sorry! You are not allowed #{name}"
  end

  def unknown_item(name)
    puts "I don't have any #{name} in stock"
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
    @restrictions.all? do |r|
      r.check(person)
    end
  end
end

# you can buy just a few things at this nanomart
require 'highline'
require 'active_support/inflector'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)
    klass = ("Item::" + item_type.to_s.camelize).constantize
    begin
       item = klass.new
    rescue NameError
       raise ArgumentError, "Don't know how to sell #{item_type}"
    end

    if item.restrictions.any?
      age = @prompter.get_age
      item.restrictions.each do |r|
        raise Nanomart::NoSale unless r.check(age)
      end
    end
    log_sale(item)
  end

  def log_sale(item)
    File.open(@logfile, 'a') do |f|
      f.write(item.name + "\n")
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
    def self.check(age)
      age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def self.check(age)
      age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def self.check(age)
      Time.now.wday != 0 # Sunday
    end
  end
end

class Item
  def name
    self.class.to_s.sub(/^Item::/, '').underscore
  end

  def try_purchase(success)
    raise Nanomart::NoSale unless success
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge, Restriction::SundayBlueLaw]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge]
    end
  end

  class Cola < Item
    def restrictions
      []
    end
  end

  class CannedHaggis < Item
    def restrictions
      []
    end
  end
end


# you can buy just a few things at this nanomart
require 'highline'

class NoSale < StandardError; end

def process_transaction_for(item_type)
  item = Item.for(item_type) or raise ArgumentError, "Don't know how to sell #{item_type}"

  item.restrictions.each do |r|
    r.check or raise NoSale
  end
  item.log_sale
end

module Restriction
  class Age
    def initialize(minimum_age)
      @minimum_age = minimum_age
    end

    def check
      age = HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
      age >= @minimum_age
    end
  end

  class SundayBlueLaw
    def check
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  DRINKING_AGE = 21
  SMOKING_AGE = 18
  INVENTORY_LOG = 'inventory.log'

  def log_sale
    File.open(INVENTORY_LOG, 'a') do |f|
      f.write(name.to_s + "\n")
    end
  end

  def restrictions
    []
  end

  def name
    self.class.name
  end

  def self.name
    self.to_s.sub(/^Item::/, '').downcase.to_sym
  end

  def self.inherited(klass)
    @@item_type_for ||= {}
    @@item_type_for[klass.name] = klass
  end

  def self.for(type)
    @@item_type_for[type].new
  end

  module Alcohol
    # you have to be of a certain age to buy alcohol
    def restrictions
      super + [Restriction::Age.new(DRINKING_AGE)]
    end
  end

  class Beer < Item
    include Alcohol
  end

  class Whiskey < Item
    include Alcohol
    def restrictions
      # you can't sell hard liquor on Sundays for some reason
      super << Restriction::SundayBlueLaw.new
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      super << Restriction::Age.new(SMOKING_AGE)
    end
  end

  class Cola < Item; end

  class CannedHaggis < Item
    # the common-case implementation of Item.name doesn't work here
    def self.name
      :canned_haggis
    end
  end
end

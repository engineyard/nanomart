# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)
    item_class = case item_type
          when :beer
            Item::Beer
          when :whiskey
            Item::Whiskey
          when :cigarettes
            Item::Cigarettes
          when :cola
            Item::Cola
          when :canned_haggis
            Item::CannedHaggis
          else
            raise ArgumentError, "Don't know how to sell #{item_type}"
          end
    item = item_class.new(@logfile, @prompter)
    item.restrictions.each do |r|
      r.check or raise NoSale
    end
    item.log_sale
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
  
  class GenericRestriction
    def initialize(p)
      @prompter = p
    end
  end

  class DrinkingAge < GenericRestriction
    def check
      @prompter.get_age >= DRINKING_AGE
    end
  end

  class SmokingAge < GenericRestriction
    def check
      @prompter.get_age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw < GenericRestriction
    def check
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end
  
  def self.inherited(base)
    base.class_eval do
      class << self
        attr_accessor :restrictions
      end
      self.restrictions ||= []
    end
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(name.to_s + "\n")
    end
  end

  def name
    self.class.to_s.sub(/^Item::/, '').downcase.to_sym
  end
  
  def restrictions
    self.class.restrictions.collect{ |r| r.new(@prompter) }
  end
  
  def self.restriction(r)
    self.restrictions << r
  end

  class Beer < Item
    restriction Restriction::DrinkingAge
  end

  class Whiskey < Item
    restriction Restriction::DrinkingAge
    # you can't sell hard liquor on Sundays for some reason
    restriction Restriction::SundayBlueLaw
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    restriction Restriction::SmokingAge
  end

  class Cola < Item
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.name doesn't work here
    def name
      :canned_haggis
    end
  end
end



if __FILE__ == $0
  nanomart = Nanomart.new('/dev/null', HighlinePrompter.new)
  what_to_buy = HighLine.new.ask('What to buy? ', String) # prompts for user's age, reads it in
  nanomart.sell_me(what_to_buy.to_sym)
end
# you can buy just a few things at this nanomart
require 'highline'


class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(name.to_s + "\n")
    end
  end

  def name
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def restrictions
    []
  end

  def can_purchase?
    if restrictions.any?
      restrictions.all? do |restriction|
        restriction.new(@prompter).check
      end
    else
      true
    end
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
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.name doesn't work here
    def name
      :canned_haggis
    end
  end
end

class Nanomart
  class NoSale < StandardError; end

  ITEM_MAPS = {
    :beer => Item::Beer,
    :whiskey => Item::Whiskey,
    :cola => Item::Cola,
    :canned_haggis => Item::CannedHaggis,
    :cigarettes => Item::Cigarettes
  }

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  # Sell an item by type.
  #
  # item_type - A type of item to sell.
  #
  # Returns nothing.
  def sell_me(item_type)
    item = item_for_type(item_type)

    raise Nanomart::NoSale unless item.can_purchase?
    item.log_sale
  end

  private

  def item_for_type(item_type)
    if type = ITEM_MAPS[item_type]
      type.new(@logfile, @prompter)
    else
      raise ArgumentError, "Don't know how to sell #{item_type}"
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
    def initialize(p)
      @prompter = p
    end

    def check
      @prompter.get_age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def initialize(p)
      @prompter = p
    end

    def check
      @prompter.get_age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def check
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

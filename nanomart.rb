# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)
    item = Item.create_by_name(item_type, @prompter)

    item.restrictions.each do |r|
      item.try_purchase(r.check)
    end
    log_sale(item)
  end

  private

  def log_sale(item)
    File.open(@logfile, 'a') do |f|
      f.write(item.name.to_s + "\n")
    end
  end
end

# class HighlinePrompter
  # def get_age
    # HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  # end
# end


module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def initialize(p)
      @prompter = p
    end

    def check
      age = @prompter.get_age
      if age >= DRINKING_AGE
        true
      else
        false
      end
    end
  end

  class SmokingAge
    def initialize(p)
      @prompter = p
    end

    def check
      age = @prompter.get_age
      if age >= SMOKING_AGE
        true
      else
        false
      end
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

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(prompter)
    @prompter = prompter
  end

  def name
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  def self.create_by_name(item_type, prompter)
    case item_type
    when :beer
      Item::Beer.new(prompter)
    when :whiskey
      Item::Whiskey.new(prompter)
    when :cigarettes
      Item::Cigarettes.new(prompter)
    when :cola
      Item::Cola.new(prompter)
    when :canned_haggis
      Item::CannedHaggis.new(prompter)
    else
      raise ArgumentError, "Don't know how to sell #{item_type}"
    end
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new(@prompter)]
    end
  end

  class Cola < Item
    def restrictions
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.name doesn't work here
    def name
      :canned_haggis
    end

    def restrictions
      []
    end
  end
end


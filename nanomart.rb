# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile)
    @logfile = logfile
  end

  def sell_me(item_type, prompter)
    item = case item_type
          when :beer
            Item::Beer.new(@logfile, prompter)
          when :whiskey
            Item::Whiskey.new(@logfile, prompter)
          when :cigarettes
            Item::Cigarettes.new(@logfile, prompter)
          when :cola
            Item::Cola.new(@logfile, prompter)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile, prompter)
          else
            raise ArgumentError, "Don't know how to sell #{item_type}"
          end

    allowed_to_purchase = item.restrictions.all? &:allowed?
    item.log_sale if allowed_to_purchase
    return allowed_to_purchase
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

    def allowed?
      age = @prompter.get_age

      age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def initialize(p)
      @prompter = p
    end

    def allowed?
      age = @prompter.get_age

      age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def allowed?
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

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
    self.class.to_s.sub(/^Item::/, '').downcase.to_sym
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


# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    # This needs to be refactored so items can be sold on their own
    # No need for this case statement with POLYMORPHISM!!!! :)
    itm = case itm_type
          when :beer
            Item::Beer.new(@logfile, @prompter)
          when :whiskey
            Item::Whiskey.new(@logfile, @prompter)
          when :cigarettes
            Item::Cigarettes.new(@logfile, @prompter)
          when :cola
            Item::Cola.new(@logfile, @prompter)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile, @prompter)
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    item.purchase
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
  attr_reader :logfile, :prompter

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(name.to_s + "\n")
    end
  end

 def restrictions
    []
 end

  def name
    raise 'Override in your subclasses. Name was complicated for no reason.'
  end

  def can_purchase?
    restrictions.all? {|restriction| restriction.check }
  end

  def purchase
    log_sale if can_purchase?
  end

  class Beer < Item
    def name; :beer end

    def restrictions
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    def name; :whiskey end
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    def name; :cigarettes end
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new(@prompter)]
    end
  end

  class Cola < Item
    def name; :cola end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def name
      :canned_haggis
    end
  end
end


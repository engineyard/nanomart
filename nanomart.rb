# you can buy just a few things at this nanomart
Bundler.require

class Nanomart
  def self.run(logfile)
    new(logfile, HighlinePrompter.new).run
  end

  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def run
    item_type = @prompter.get_item
    sell_me(item_type.to_sym)
  end

  def sell_me(item_type)
    itm = case item_type
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
            raise ArgumentError, "Don't know how to sell #{item_type}"
          end

    itm.try_purchase
    itm.log_sale
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end

  def get_item
    HighLine.new.ask('Item? ', String)
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
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
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

  def try_purchase
    restrictions.each do |r|
      unless r.check
        raise Nanomart::NoSale
      end
    end
    true
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
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end

    def restrictions
      []
    end
  end
end


# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
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

    # check item for restrictions
    itm.rstrctns.each do |r|
      itm.try_purchase(r.ck)
    end
    # it's all good: sale is ok
    itm.log_sale
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


class Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  def initialize(p)
    @prompter = p
  end

  class DrinkingAge < Restriction
    def ck
      # true = no restriction
      @prompter.get_age >= DRINKING_AGE
    end
  end

  class SmokingAge< Restriction

    def ck
      # true = no restriction
      @prompter.get_age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw < Restriction

    def ck
      # pp Time.now.wday
      # debugger
      # true = no restriction
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
      f.write(@name + "\n")
    end
  end

  def try_purchase(success)
    if success
      # no restriction
      return true
    else
      raise Nanomart::NoSale
    end
  end

  class Beer < Item
    def initialize(*)
      @name = "beer"
      super
    end
    # you have to be of a certain age to buy beer
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    def initialize(*)
      @name = "whiskey"
      super
    end
    # you have to be of a certain age to buy whiskey
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    def initialize(*)
      @name = "cigarettes"
      super
    end
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [Restriction::SmokingAge.new(@prompter)]
    end
  end

  class Cola < Item
    def initialize(*)
      @name = "cola"
      super
    end
    # there are no restrictions
    def rstrctns
      []
    end
  end

  class CannedHaggis < Item
    def initialize(*)
      @name = "canned_haggis"
      super
    end

    # there are no restrictions
    def rstrctns
      []
    end
  end
end


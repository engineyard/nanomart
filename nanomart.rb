# you can buy just a few things at this nanomart
require 'highline'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_class)
    itm = itm_class.new(@logfile, @prompter) or raise ArgumentError, "Don't know how to sell #{itm_class}"

    itm.rstrctns.each do |r|
      itm.try_purchase(r.ck)
    end
  end

  def can_sell_me(itm_class)
    itm = itm_class.new(@logfile, @prompter) or raise ArgumentError, "Don't know how to sell #{itm_class}"

    itm.rstrctns.all? do |r|
      r.ck
    end
  end

  def log_sale(itm)
    File.open(@logfile, 'a') do |f|
      f.write(itm.nam.to_s + "\n")
    end
  end

end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


class Restriction
  def restriction_age
    18
  end

  def initialize(p)
    @prompter = p
  end

  class DrinkingAge < Restriction
    def restriction_age
      21
    end
    def ck
      @prompter.get_age >= restriction_age
    end
  end

  class SmokingAge < Restriction
    def ck
      @prompter.get_age >= restriction_age
    end
  end

  class SundayBlueLaw < Restriction
    def ck
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'
  def rstrctns
    []
  end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase(success)
      success or raise Nanomart::NoSale
  end

  class Beer < Item
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [Restriction::SmokingAge.new(@prompter)]
    end
  end

  class Cola < Item
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end
  end
end


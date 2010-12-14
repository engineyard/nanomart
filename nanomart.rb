# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    # constant = itm_type.constantize
    # itm = constant.new(@logfile, @prompter)
    itm = case itm_type
          when :beer
            Beer.new(@logfile, @prompter)
          when :whiskey
            Whiskey.new(@logfile, @prompter)
          when :cigarettes
            Cigarettes.new(@logfile, @prompter)
          when :cola
            Cola.new(@logfile, @prompter)
          when :canned_haggis
            CannedHaggis.new(@logfile, @prompter)
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    itm.rstrctns.each do |r|
      if ! r.ck
        raise Nanomart::NoSale
      end
    end
    
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
end

class DrinkingAge < Restriction
  def ck
    @prompter.get_age >= DRINKING_AGE
  end
end

class SmokingAge< Restriction
  def ck
    @prompter.get_age >= SMOKING_AGE
  end
end

class SundayBlueLaw < Restriction
  def ck
    # pp Time.now.wday
    # debugger
    Time.now.wday != 0      # 0 is Sunday
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(nam + "\n")
    end
  end

  def nam
    self.class.to_s.downcase
  end

end

class Beer < Item
  def rstrctns
    [DrinkingAge.new(@prompter)]
  end
end

class Whiskey < Item
  # you can't sell hard liquor on Sundays for some reason
  def rstrctns
    [DrinkingAge.new(@prompter), SundayBlueLaw.new(@prompter)]
  end
end

class Cigarettes < Item
  # you have to be of a certain age to buy tobacco
  def rstrctns
    [SmokingAge.new(@prompter)]
  end
end

class Cola < Item
  def rstrctns
    []
  end
end

class CannedHaggis < Item
  # the common-case implementation of Item.nam doesn't work here
  def nam
    :canned_haggis.to_s
  end

  def rstrctns
    []
  end
end
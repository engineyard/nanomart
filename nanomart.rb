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
            Item::Beer.new(@logfile, @prompter, :alcohol)
          when :whiskey
            Item::Whiskey.new(@logfile, @prompter, :alcohol, :blue)
          when :cigarettes
            Item::Cigarettes.new(@logfile, @prompter, :smoke)
          when :cola
            Item::Cola.new(@logfile, @prompter)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile, @prompter)
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    itm.rstrctns.each do |r|
      itm.try_purchase(r.ck(itm))
    end
    itm.log_sale
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

  class AgeLimit
    def initialize(p)
      @prompter = p;
    end
   
    def ck (itm)
      age = @prompter.get_age
      age_limit = age
      limit = itm.types.each do |t|
        if (t == :alcohol) 
          age_limit = DRINKING_AGE
        elsif(t == :smoke) 
          age_limit = SMOKING_AGE
        end
      end
      if age >= age_limit
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

    def ck (itm)
      age = @prompter.get_age
      limit = itm.types.all? do |t|
        if (t == :blue)
          # pp Time.now.wday
          # debugger
          Time.now.wday != 0      # 0 is Sunday
        else
          true
        end
      end
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter, *types)
    @logfile, @prompter, @types = logfile, prompter, types
  end

  attr_reader :types
  
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

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  class RestrItem < Item
    def rstrctns
      [Restriction::AgeLimit.new(@prompter)]
    end
  end

  class Beer < Item
    def rstrctns
      [Restriction::AgeLimit.new(@prompter)]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [Restriction::AgeLimit.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [Restriction::AgeLimit.new(@prompter)]
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
      :canned_haggis
    end

    def rstrctns
      []
    end
  end
end


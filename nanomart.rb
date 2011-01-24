# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, preference_list)
    @logfile, @preference_list = logfile, preference_list
  end

  def sell_me(itm_type)
    itm = case itm_type
          when :beer
            Item::Beer.new(@logfile, @preference_list)
          when :whiskey
            Item::Whiskey.new(@logfile, @preference_list)
          when :cigarettes
            Item::Cigarettes.new(@logfile, @preference_list)
          when :cola
            Item::Cola.new(@logfile, @preference_list)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile, @preference_list)
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    itm.rstrctns.each do |r|
      itm.try_purchase(r.ck)
    end

    itm.log_sale
  end
end

class HighlinePrompter
  def get_restriction_value
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end

  def preference_type
    :undef
  end
end

class AgePrompter
  def get_restriction_value
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end

  def preference_type
    :age
  end
end

module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def initialize(p)
      @preference_list = p
    end

    def ck
      @preference_list.each do |preference|
        if preference.preference_type == :age && preference.get_restriction_value >= DRINKING_AGE
          return true
        else
          return false
        end
      end
    end
  end

  class SmokingAge
    def initialize(p)
      @preference_list = p
    end

    def ck
      @preference_list.each do |preference|
        if preference.preference_type == :age && preference.get_restriction_value >= SMOKING_AGE
          return true
        else
          return false
        end
      end
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @preference_list = p
    end

    def ck
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, preference_list)
    @logfile, @preference_list = logfile, preference_list
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(nam + "\n")
    end
  end

  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    short_class_string.downcase
  end

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  class Beer < Item
    def rstrctns
      [Restriction::DrinkingAge.new(@preference_list)]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [Restriction::DrinkingAge.new(@preference_list), Restriction::SundayBlueLaw.new(@preference_list)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [Restriction::SmokingAge.new(@preference_list)]
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
      'canned_haggis'
    end

    def rstrctns
      []
    end
  end
end


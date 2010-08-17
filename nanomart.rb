# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  PRODUCTS = [:cola, :canned_haggis, :cigarettes, :beer, :whiskey]

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    args = [@logfile, @prompter]

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

    itm.rstrctns.each do |r|
      r.can_buy? or raise NoSale
    end
    itm.log_sale
  end
end

class HighlinePrompter
  def get_age
    @age ||= HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end

  def get_product
    @hl = HighLine.new

    @hl.choose do |menu|
      menu.prompt = "What do you want?  "

      Nanomart::PRODUCTS.each do |product|
        menu.choice(product) { return product }
      end

      menu.choice('Nothing.  Bye.') { exit }
    end
  end
end


module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def initialize(p)
      @prompter = p
    end

    def can_buy?
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

    def can_buy?
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

    def can_buy?
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
      f.write(symbolize.to_s + "\n")
    end
  end

  def symbolize
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
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
    def rstrctns
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.symbolize doesn't work here
    def symbolize
      :canned_haggis
    end

    def rstrctns
      []
    end
  end
end



def main
  @prompter = HighlinePrompter.new
  @nanomart = Nanomart.new('log.txt', @prompter)
  @age = @prompter.get_age
  loop do
    begin
      @product = @prompter.get_product
      @nanomart.sell_me(@product)
      puts 'Gotcha.'
    rescue Nanomart::NoSale
      puts 'NO!'
    end
  end
end

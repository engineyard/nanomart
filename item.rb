require 'restriction'

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

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  class Beer < Item
    def name
      :beer
    end
    
    def restrictions
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    def name
      :whiskey
    end

    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    def name
      :cigarettes
    end

    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new(@prompter)]
    end
  end

  class Cola < Item
    def name
      :cola
    end

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


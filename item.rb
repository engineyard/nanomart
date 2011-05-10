require 'restriction'

class Item
  INVENTORY_LOG = 'inventory.log'
  
  RESTRICTIONS = {:beer => [Restriction::DrinkingAge], 
    :whiskey => [Restriction::DrinkingAge, Restriction::SundayBlueLaw],
    :cigarettes => [Restriction::SmokingAge], :canned_haggis => [],
    :cola => []}

  def initialize(item_type, logfile, prompter)
    unless RESTRICTIONS.has_key?(item_type)
      raise Nanomart::NoSale
    end
    
    @item_type, @logfile, @prompter = item_type, logfile, prompter
    populate_restrictions
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
  
  def name
    @item_type
  end

  def restrictions
    @restrictions
  end
  
  protected
  
  def populate_restrictions
    @restrictions = []
    RESTRICTIONS[@item_type].each do |r|
      @restrictions << r.new(@prompter)
    end
  end
end


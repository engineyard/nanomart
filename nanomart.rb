# you can buy just a few things at this nanomart
require 'highline'
require 'item'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
    
    @items = {:beer => Item::Beer, :whiskey => Item::Whiskey, 
        :cigarettes => Item::Cigarettes, :cola => Item::Cola, 
        :canned_haggis => Item::CannedHaggis }
  end

  def create_item(item_type)
    Item.new(item_type, @logfile, @prompter)
  end

  def sell_me(item_type)
    item = create_item(item_type)
    item.restrictions.each do |r|
      item.try_purchase(r.check)
    end
    item.log_sale
  end
end

# you can buy just a few things at this nanomart
require 'item'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, age)
    @logfile, @age = logfile, age
  end

  def create_item(item_type)
    Item.new(item_type, @logfile, @age)
  end

  def sell_me(item_type)
    item = create_item(item_type)
    item.restrictions.each do |r|
      item.try_purchase(r.check)
    end
    item.log_sale
  end
end

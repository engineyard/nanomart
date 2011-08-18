# you can buy just a few things at this nanomart
require 'highline'

require "lib/highline_prompter"
require "lib/item"
require "lib/restriction"

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(item_type)

    item_class = Item.items.detect{ |klass| klass.item_name == item_type }

    if item
      item = item_class.new(@logfile, @prompter)
    else
      raise ArgumentError, "Don't know how to sell #{item_type}"
    end

    item.restrictions.each do |r|
      item.try_purchase(r.check)
    end
    item.log_sale
  end
end


# you can buy just a few things at this nanomart
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'item'
require 'logger'

class Nanomart
  INVENTORY_LOG = 'inventory.log'
  class NoSale < StandardError; end

  def initialize(prompter:, logger: Logger.new(logfile: INVENTORY_LOG))
    @logger, @prompter = logger, prompter
  end

  def sell_me(item_type)
    item = case item_type
          when :beer
            Item::Beer.new
          when :whiskey
            Item::Whiskey.new
          when :cigarettes
            Item::Cigarettes.new
          when :cola
            Item::Cola.new
          when :canned_haggis
            Item::CannedHaggis.new
          else
            raise ArgumentError, "Don't know how to sell #{item_type}"
          end

    if item.can_sell_to?(@prompter)
      @logger.log(item.name)
      true
    else
      false
    end
  end
end

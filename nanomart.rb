# you can buy just a few things at this nanomart
require 'highline'
require 'item'
require 'restriction'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    require 'lib/items/general'
    require 'lib/items/table'

    itm = nil
    Item.subcl.each do |klass|
      if klass.nam == itm_type
        itm = klass.new(@logfile, @prompter)
      end
    end
    raise ArgumentError, "Don't know how to sell #{itm_type}" if itm.nil?

    itm.rstrctns.each do |r|
      itm.try_purchase(r.ck)
    end
    itm.log_sale
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end




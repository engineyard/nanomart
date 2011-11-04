# you can buy just a few things at this nanomart
require 'highline'
require 'active_support/all'
require 'logger'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logger, @prompter = Logger.new(logfile), prompter
  end

  def sell_me(itm_type)
    klass = "Item::#{itm_type.to_s.camelize}".constantize
    klass.restrictions.each { |rule| raise NoSale unless rule.call(@prompter) }

    itm = klass.new
    @logger.info(itm.name)
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end

class Item
  def name
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end


  module RestrictionLogic
    def restrictions
      @restrictions ||= []
    end
    def drinking_age
      restrictions << lambda { |prompt| prompt.get_age >= 21 }
    end
    def smoking_age
      restrictions << lambda { |prompt| prompt.get_age >= 18 }
    end
    def sunday_blue_law
      restrictions << lambda { |prompt| Time.now.wday != 0 }
    end
  end

  extend RestrictionLogic

  class Beer < Item
    drinking_age
  end

  class Whiskey < Item
    drinking_age
    sunday_blue_law
  end

  class Cigarettes < Item
    smoking_age
  end

  class Cola < Item
  end

  class Pineapple < Item
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def name
      :canned_haggis
    end
  end
end


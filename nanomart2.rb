require 'highline'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end
  
  DRINKING_AGE = 21
  SMOKING_AGE = 18
  NONE = 0

  class Item
    def initialize(name, required_age)
      @name = name
      @required_age = required_age
    end
    attr_reader :name

    def old_enough?(buyers_age)
      buyers_age >= @required_age
    end

  end
  
  def sell_me(itm_type)
    itm = case itm_type
          when :beer
            Item.new("beer", DRINKING_AGE)
          when :whiskey
            Item.new("whiskey", DRINKING_AGE)
          when :cigarettes
            Item.new("cigarettes", SMOKING_AGE)
          when :cola
            Item.new("cola", NONE)
          when :canned_haggis
            Item.new("canned_haggis", NONE)
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end
    
    puts "Trying to buy #{itm.name}"
    
    puts "What is prompter " + @prompter.inspect
    
    puts "What is prompter.get_age " + @prompter.get_age.inspect
    
    #is it sunday
    if itm.name == "whiskey" && Time.now.wday == 0
      raise NoSale
    end
    
    # old_enough?
    unless itm.old_enough?(@prompter.get_age)
      raise NoSale
    end
  
  end
  
  
  
  
end

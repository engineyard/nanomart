# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile="nanomart.log", prompter=HighlinePrompter.new)
    @logfile, @prompter = logfile, prompter
  end

  attr_reader :logfile, :prompter

  def age
    @age ||= prompter.get_age
  end

  def logger
    @logger ||= File.open(logfile, "a")
  end

  def log(item)
    logger.puts item.name
    logger.flush
  end

  def sell_me(item_name)
    item = Item.get(item_name)
    item.check(self).tap do |res|
      log(item) if res
    end
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end

class Item
  @@items = {}
  def self.register(name, restrictions=[])
    @@items[name] = new(name, restrictions)
  end

  def self.get(name)
    @@items[name]
  end

  def self.all
    @@items
  end

  attr_accessor :name

  def restrictions
    @restrictions.map{|r| Restriction.get(r) }
  end

  def initialize(name, restrictions=[])
    @name, @restrictions = name, restrictions
  end

  def check(mart)
    restrictions.all? do |r|
      r.valid?(mart)
    end
  end
end

class Restriction
  @@restrictions = {}
  def self.register(name, &blk)
    @@restrictions[name] = new(name,blk)
  end

  def self.all
    @@restrictions
  end

  def self.get(name)
    @@restrictions[name]
  end

  attr_accessor :name, :blk

  def initialize(name, blk)
    @name, @blk = name, blk
  end

  def valid?(mart)
    blk.call(mart)
  end
end

Restriction.register(:over_21) do |mart|
  mart.age > 21
end

Restriction.register(:over_18) do |mart|
  mart.age > 18
end

Restriction.register(:no_sundays) do |mart|
  Time.now.wday != 0
end

Item.register(:cola)
Item.register(:canned_haggis)
Item.register(:cigarettes, [:over_18])
Item.register(:beer, [:over_21])
Item.register(:whiskey, [:over_21, :no_sundays])

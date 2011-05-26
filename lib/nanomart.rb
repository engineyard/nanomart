# you can buy just a few things at this nanomart
require 'highline'


class Nanomart
  class NoSale < StandardError; end

  attr_reader :age
  
  def initialize(age)
    @age = age
  end
  
  def self.items
    @@items = {
      :beer => [restrictions[:drinking]],
      :whiskey => [restrictions[:drinking], restrictions[:blue_law]],
      :cigarettes => [restrictions[:smoking]],
      :cola => [],
      :canned_haggis => []
    }
  end

  def self.restrictions
    @@restrictions = {
      :drinking => lambda{|age| age >= 21},
      :smoking => lambda{|age| age >= 18},
      :blue_law => lambda{|age| Time.now.wday != 0}
    }
  end

  def sell_me(item_type)
    raise ArgumentError, "Don't know how to sell #{item_type}" unless Nanomart.items.key?(item_type)
    raise Nanomart::NoSale unless Nanomart.items[item_type].inject(true){|r,e| r && e.call(@age)}
  end
end
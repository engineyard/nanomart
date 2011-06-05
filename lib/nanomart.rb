# you can buy just a few things at this nanomart
require 'highline'

class Nanomart
  class NoSale < StandardError; end

  RESTRICTIONS = { :drinking => lambda{|age| age >= 21},
                   :smoking  => lambda{|age| age >= 18},
                   :blue_law => lambda{|age| Time.now.wday != 0} }

  ITEM_RESTRICTIONS = { :beer          => [RESTRICTIONS[:drinking]],
                        :whiskey       => [RESTRICTIONS[:drinking], RESTRICTIONS[:blue_law]],
                        :cigarettes    => [RESTRICTIONS[:smoking]],
                        :cola          => [],
                        :canned_haggis => [] }
  attr_reader :age
  
  def initialize(age)
    @age = age
  end
  
  def have_item?(item)
    Nanomart::ITEM_RESTRICTIONS.key?(item)
  end

  def allowed_to_buy?(item)
    Nanomart::ITEM_RESTRICTIONS[item].all? do |restriction| 
      restriction.call(age)
    end
  end

  def sell_me(item)
    raise ArgumentError, "Don't have #{item}." unless have_item?(item)
    raise Nanomart::NoSale                     unless allowed_to_buy?(item)
  end
end


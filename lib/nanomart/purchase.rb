class Nanomart::Purchase
  RESTRICTIONS = {
    :drinking => lambda{|purchase| purchase.customer.age >= 21},
    :smoking  => lambda{|purchase| purchase.customer.age >= 18},
    :blue_law => lambda{|purchase| purchase.date.wday != 0}
  }

  ITEMS = {
    :beer          => [RESTRICTIONS[:drinking]],
    :whiskey       => [RESTRICTIONS[:drinking], RESTRICTIONS[:blue_law]],
    :cigarettes    => [RESTRICTIONS[:smoking]],
    :cola          => [],
    :canned_haggis => []
  }

  def self.build(item, customer, options={})
    options[:on] ||= Time.now
    Nanomart::Purchase.new(item, customer, options[:on])
  end

  attr_reader :item, :customer, :date, :successful

  def initialize(item, customer, date)
    @item, @customer, @date = item, customer, date
  end

  def buy
    @successful = ITEMS[item].all?{|restriction| restriction.call(self)}; self
  end

  def successful?
    @successful
  end
end

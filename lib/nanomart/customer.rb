class Nanomart::Customer
  attr_reader :age

  def initialize(options={})
    @age = options[:age]
  end

  def purchase(item, options={})
    Nanomart::Purchase.build(item, self, options).buy
  end
end

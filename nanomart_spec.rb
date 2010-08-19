Bundler.require(:test)

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'

class MockPerson
  def initialize(age)
    @age = age
    @items = []
  end
  attr_reader :items

  def get_age
    @age
  end

  def take_item(name)
    @items << name
  end
end

describe "making sure the customer is old enough" do
  context "when you're a kid" do
    before(:each) do
      @person   = MockPerson.new(9)
      @nanomart = Nanomart.new('/dev/null', @person)
    end

    it "lets you buy cola and canned haggis" do
      @nanomart.sell_me(:cola)
      @nanomart.sell_me(:canned_haggis)
      @person.should have(2).items
    end

    it "stops you from buying anything age-restricted" do
      @nanomart.sell_me(:beer)
      @nanomart.sell_me(:whiskey)
      @nanomart.sell_me(:cigarettes)
      @person.should have(0).items
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @person   = MockPerson.new(19)
      @nanomart = Nanomart.new('/dev/null', @person)
    end

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      @nanomart.sell_me(:cola)
      @nanomart.sell_me(:canned_haggis)
      @nanomart.sell_me(:cigarettes)
      @person.should have(3).items
    end

    it "stops you from buying anything age-restricted" do
      @nanomart.sell_me(:beer)
      @nanomart.sell_me(:whiskey)
      @person.should have(0).items
    end
  end

  context "when you're an old fogey on Thursday" do
    before(:each) do
      @person   = MockPerson.new(99)
      @nanomart = Nanomart.new('/dev/null', @person)
      Time.stub!(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      @nanomart.sell_me(:cola)
      @nanomart.sell_me(:canned_haggis)
      @nanomart.sell_me(:cigarettes)
      @nanomart.sell_me(:beer)
      @nanomart.sell_me(:whiskey)
      @person.should have(5).items
    end
  end

  context "when you're an old fogey on Sunday" do
    before(:each) do
      @person   = MockPerson.new(99)
      @nanomart = Nanomart.new('/dev/null', @person)
      Time.stub!(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      @nanomart.sell_me(:whiskey)
      @person.should have(0).items
    end
  end
end


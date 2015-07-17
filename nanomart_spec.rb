require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'

class Age9
  def get_age() 9 end
end

class Age19
  def get_age() 19 end
end

class Age99
  def get_age() 99 end
end

describe "making sure the customer is old enough" do
  context "when you're a kid" do
    let(:nanomart) { Nanomart.new(prompter: Age9.new) }

    it "lets you buy cola and canned haggis" do
      nanomart.sell_me(:cola).should be_true
      nanomart.sell_me(:canned_haggis).should be_true
    end

    it "stops you from buying anything age-restricted" do
      nanomart.sell_me(:beer).should be_false
      nanomart.sell_me(:whiskey).should be_false
      nanomart.sell_me(:cigarettes).should be_false
    end
  end

  context "when you're a newly-minted adult" do
    let(:nanomart) { Nanomart.new(prompter: Age19.new) }

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      nanomart.sell_me(:cola).should be_true
      nanomart.sell_me(:canned_haggis).should be_true
      nanomart.sell_me(:cigarettes).should be_true
    end

    it "stops you from buying anything age-restricted" do
      nanomart.sell_me(:beer).should be_false
      nanomart.sell_me(:whiskey).should be_false
    end
  end

  context "when you're an old fogey on Thursday" do
    let(:nanomart) { Nanomart.new(prompter: Age99.new) }
    before(:each) do
      Time.stub(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      nanomart.sell_me(:cola).should be_true
      nanomart.sell_me(:canned_haggis).should be_true
      nanomart.sell_me(:cigarettes).should be_true
      nanomart.sell_me(:beer).should be_true
      nanomart.sell_me(:whiskey).should be_true
    end
  end

  context "when you're an old fogey on Sunday" do
    let(:nanomart) { Nanomart.new(prompter: Age99.new) }
    before(:each) do
      Time.stub(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      nanomart.sell_me(:whiskey).should be_false
    end
  end

  describe "logging a sale" do
    let(:logger_double) { double Logger }
    let(:prompter) { Age9.new }
    let(:nanomart) { Nanomart.new(prompter: prompter, logger: logger_double) }
    let(:item) { Item::Cola.new }

    it "logs the name of a sold item" do
      expect(logger_double).to receive(:log).with(item.name)
      nanomart.sell_me(:cola)
    end
  end
end


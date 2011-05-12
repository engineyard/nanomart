require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'
LOG_FILE = "george.log"

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
    before(:each) do
      @nanomart = Nanomart.new(LOG_FILE, Age9.new)
    end

    it "lets you buy cola and canned haggis" do
      lambda { @nanomart.sell_me(Item::Cola)          }.should_not raise_error
      lambda { @nanomart.sell_me(Item::CannedHaggis) }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @nanomart.sell_me(Item::Beer)       }.should raise_error(Nanomart::NoSale)
      lambda { @nanomart.sell_me(Item::Whiskey)    }.should raise_error(Nanomart::NoSale)
      lambda { @nanomart.sell_me(Item::Cigarettes) }.should raise_error(Nanomart::NoSale)
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @nanomart = Nanomart.new(LOG_FILE, Age19.new)
    end

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      lambda { @nanomart.sell_me(Item::Cola)          }.should_not raise_error
      lambda { @nanomart.sell_me(Item::CannedHaggis) }.should_not raise_error
      lambda { @nanomart.sell_me(Item::Cigarettes)    }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @nanomart.sell_me(Item::Beer)       }.should raise_error(Nanomart::NoSale)
      lambda { @nanomart.sell_me(Item::Whiskey)    }.should raise_error(Nanomart::NoSale)
    end
  end

  context "when you're an old fogey on Thursday" do
    before(:each) do
      @nanomart = Nanomart.new(LOG_FILE, Age99.new)
      Time.stub!(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      lambda { @nanomart.sell_me(Item::Cola)          }.should_not raise_error
      lambda { @nanomart.sell_me(Item::CannedHaggis) }.should_not raise_error
      lambda { @nanomart.sell_me(Item::Cigarettes)    }.should_not raise_error
      lambda { @nanomart.sell_me(Item::Beer)          }.should_not raise_error
      lambda { @nanomart.sell_me(Item::Whiskey)       }.should_not raise_error
    end
  end

  context "when you're an old fogey on Sunday" do
    before(:each) do
      @nanomart = Nanomart.new(LOG_FILE, Age99.new)
      Time.stub!(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      lambda { @nanomart.sell_me(Item::Whiskey)       }.should raise_error(Nanomart::NoSale)
    end
  end
end


require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'

describe "making sure the customer is old enough" do
  context "when you're a kid" do
    before(:each) do
      @nanomart = Nanomart.new
    end

    it "lets you buy cola and canned haggis" do
      lambda { @nanomart.sell_me(:cola, 9)          }.should_not raise_error
      lambda { @nanomart.sell_me(:canned_haggis, 9) }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @nanomart.sell_me(:beer, 9)       }.should raise_error(Item::NoSale)
      lambda { @nanomart.sell_me(:whiskey, 9)    }.should raise_error(Item::NoSale)
      lambda { @nanomart.sell_me(:cigarettes, 9) }.should raise_error(Item::NoSale)
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @nanomart = Nanomart.new
    end

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      lambda { @nanomart.sell_me(:cola, 19)          }.should_not raise_error
      lambda { @nanomart.sell_me(:canned_haggis, 19) }.should_not raise_error
      lambda { @nanomart.sell_me(:cigarettes, 19)    }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @nanomart.sell_me(:beer, 19)       }.should raise_error(Item::NoSale)
      lambda { @nanomart.sell_me(:whiskey, 19)    }.should raise_error(Item::NoSale)
    end
  end

  context "when you're an old fogey on Thursday" do
    before(:each) do
      @nanomart = Nanomart.new
      Time.stub!(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      lambda { @nanomart.sell_me(:cola, 99)          }.should_not raise_error
      lambda { @nanomart.sell_me(:canned_haggis, 99) }.should_not raise_error
      lambda { @nanomart.sell_me(:cigarettes, 99)    }.should_not raise_error
      lambda { @nanomart.sell_me(:beer, 99)          }.should_not raise_error
      lambda { @nanomart.sell_me(:whiskey, 99)       }.should_not raise_error
    end
  end

  context "when you're an old fogey on Sunday" do
    before(:each) do
      @nanomart = Nanomart.new
      Time.stub!(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      lambda { @nanomart.sell_me(:whiskey, 99)       }.should raise_error(Item::NoSale)
    end
  end
end


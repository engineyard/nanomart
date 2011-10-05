require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'

require 'tempfile'

class Age9
  def get_age() 9 end
end

class Age18
  def get_age() 18 end
end

class Age99
  def get_age() 99 end
end

class Item
  class AgeRestricted < Item
    def restrictions
      [Restriction::SmokingAge]
    end
  end

  class AnotherItem < Item
  end
end

describe "making sure the customer is old enough" do
  context "when you're a kid" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age9.new)
    end

    it "lets you buy cola and canned haggis" do
      lambda { @nanomart.sell_me(:cola)          }.should_not raise_error
      lambda { @nanomart.sell_me(:canned_haggis) }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @nanomart.sell_me(:beer)       }.should raise_error(Nanomart::NoSale)
      lambda { @nanomart.sell_me(:whiskey)    }.should raise_error(Nanomart::NoSale)
      lambda { @nanomart.sell_me(:cigarettes) }.should raise_error(Nanomart::NoSale)
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age18.new)
    end

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      lambda { @nanomart.sell_me(:cola)          }.should_not raise_error
      lambda { @nanomart.sell_me(:canned_haggis) }.should_not raise_error
      lambda { @nanomart.sell_me(:cigarettes)    }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @nanomart.sell_me(:beer)       }.should raise_error(Nanomart::NoSale)
      lambda { @nanomart.sell_me(:whiskey)    }.should raise_error(Nanomart::NoSale)
    end
  end

  context "when you're an old fogey on Thursday" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age99.new)
      Time.stub!(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      lambda { @nanomart.sell_me(:cola)          }.should_not raise_error
      lambda { @nanomart.sell_me(:canned_haggis) }.should_not raise_error
      lambda { @nanomart.sell_me(:cigarettes)    }.should_not raise_error
      lambda { @nanomart.sell_me(:beer)          }.should_not raise_error
      lambda { @nanomart.sell_me(:whiskey)       }.should_not raise_error
    end
  end

  context "when you're an old fogey on Sunday" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age99.new)
      Time.stub!(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      lambda { @nanomart.sell_me(:whiskey)       }.should raise_error(Nanomart::NoSale)
    end
  end

  context 'when logging a sale' do
    before :each do
      @logfile = Tempfile.new('logfile')
    end

    after :each do
      @logfile.unlink
    end

    it 'should log the item nam to the logfile' do
      Nanomart.new(@logfile.path, Age9.new).log_sale(Item::AgeRestricted.new)

      @logfile.rewind
      @logfile.read.should == "agerestricted\n"
    end

    it 'should append additional items to the logfile' do
      Nanomart.new(@logfile.path, Age9.new).log_sale(Item::AgeRestricted.new)
      Nanomart.new(@logfile.path, Age9.new).log_sale(Item::AnotherItem.new)

      @logfile.rewind
      @logfile.read.should == <<HERE
agerestricted
anotheritem
HERE
    end
  end
end

describe Item do
  context "when trying to purchase" do
    context "without any restrictions" do
      before :each do
        @itm = Item.new
      end

      it "should allow a kid to purchase by purchase" do
	@itm.try_purchase(Age9.new).should be_true
      end

      it "should allow a newly-minted adult to purchase" do
	@itm.try_purchase(Age18.new).should be_true
      end

      it "should allow an old fokey to purchase" do
	@itm.try_purchase(Age99.new).should be_true
      end
    end

    context "with an age restriction of 18" do
      before :each do
        @itm = Item::AgeRestricted.new
      end

      it "should not allow a kid to purchase by purchase" do
	lambda { @itm.try_purchase(Age9.new) }.should raise_error(Nanomart::NoSale)
      end

      it "should allow a newly-minted adult to purchase" do
	@itm.try_purchase(Age18.new).should be_true
      end

      it "should allow an old fokey to purchase" do
	@itm.try_purchase(Age18.new).should be_true
      end
    end
  end
end

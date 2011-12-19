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


describe Item do
  before(:each) do
    @item = Item.new(@logfile, @prompter)
  end

  it "has a logfile" do
    @item.logfile.should == @logfile
  end

  it "has restrictions" do
    @item.restrictions.should be_an_instance_of(Array)
  end

  it "has a prompter for receiving user input" do
    @item.prompter.should == @prompter
  end

  it "have a stub for the name (override in subclasses)" do
    lambda{ @item.name }.should raise_error
  end

  describe "logging a sale" do
    it "should log the sale of the item" do
      write_only = 'a'
      File.should_receive(:open).with(@item.logfile, write_only)
      @item.log_sale
    end
  end

  describe "Purchasing an item" do
    before(:each) do
      @restricted = mock('Restriction', :check => false)
      @unrestricted = mock('Restriction', :check => true)
    end
  
    it "cannot be purchased if a restriction fails the check" do
      @item.stub :restrictions => [@restricted, @unrestricted]
      @item.can_purchase?.should be_false
    end

    it "can be purchaed if all the restrictions pass the check" do
      @item.stub :restrictions => [@unrestricted]
      @item.can_purchase?.should be_true
    end

    it "logs the item's sale if it can be purchased" do
        @item.stub :can_purchase? => true
        @item.should_receive(:log_sale)
        @item.purchase
    end
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
      @nanomart = Nanomart.new('/dev/null', Age19.new)
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
end


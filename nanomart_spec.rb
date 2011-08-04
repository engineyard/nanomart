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
  
  context "when you don't know your age on sunday" do
    before(:each) do
      class Clueless
        def get_age
          raise "Don't know"
        end
      end
      @nanomart = Nanomart.new('/dev/null', Clueless.new)
      Time.stub!(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "doesn't matter for whiskey buying" do
      lambda { @nanomart.sell_me(:whiskey)       }.should raise_error(Nanomart::NoSale)
    end
  end
  
  context "when attempting to buy an unknown product" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age99.new)
    end

    it "raises an error" do
      lambda { @nanomart.sell_me(:kleenex) }.should raise_error(ArgumentError, "Don't know how to sell kleenex")
    end
  end
  
  context "logging sales" do
    before(:each) do
      @nanomart = Nanomart.new('nanomart.log', Age9.new)
    end
    
    after(:each) do
      FileUtils.rm("nanomart.log") if File.exists?("nanomart.log")
    end
    
    it "logs the name of each purchased item" do
      @nanomart.sell_me(:cola)
      @nanomart.sell_me(:canned_haggis)
      
      File.read("nanomart.log").should == "cola\ncanned_haggis\n"
    end
    
    it "doesn't log products that are restricted" do
      lambda { @nanomart.sell_me(:whiskey) }.should raise_error
      File.should_not exist("nanomart.log")
    end
  end
end

describe Item do
  describe ".name" do
    it "returns the name of Whiskey" do
      Item::Whiskey.new.name.should == :whiskey
    end
    it "returns the name of CannedHaggis" do
      Item::CannedHaggis.new.name.should == :canned_haggis
    end
  end
end
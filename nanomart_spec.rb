require 'spec'
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
  before { @log = StringIO.new }

  context "when you're a kid" do
    before(:each) do
      @nanomart = Nanomart.new(@log, Age9.new)
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
    
    it "logs the name of any item that is sold" do
      @nanomart.sell_me(:cola)
      @log.rewind
      @log.read.should =~ /cola sold/
    end
    
    it "does not log the name of any item that is restricted" do
      begin
        @nanomart.sell_me(:cigarettes)
      rescue Nanomart::NoSale
      end
      
      @log.rewind
      @log.read.should_not =~ /sold/
    end    
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @nanomart = Nanomart.new(@log, Age19.new)
    end

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      lambda { @nanomart.sell_me(:cola)          }.should_not raise_error
      lambda { @nanomart.sell_me(:canned_haggis) }.should_not raise_error
      lambda { @nanomart.sell_me(:cigarettes)    }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { @nanomart.sell_me(:beer) }
    end
  end

  context "when you're an old fogey on Thursday" do
    before(:each) do
      @nanomart = Nanomart.new(@log, Age99.new)
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
      @nanomart = Nanomart.new(@log, Age99.new)
      Time.stub!(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      lambda { @nanomart.sell_me(:whiskey)       }.should raise_error(Nanomart::NoSale)
    end
  end
end


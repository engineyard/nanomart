require 'spec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'
require 'tempfile'


class Age9 < HighlinePrompter
  def get_age() 9 end
end

class Age19 < HighlinePrompter
  def get_age() 19 end
end

class Age99 < HighlinePrompter
  def get_age() 99 end
end

describe "making sure the customer is old enough" do
  context "when you're a kid" do
    before(:each) do
      @log_path = Tempfile.new("test").path
      @nanomart = Nanomart.new(@log_path, Age9.new)
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
    
    context "when you buy cola" do
      before(:each) do
        lambda { @nanomart.sell_me(:cola)          }.should_not raise_error        
      end
      
      it "should log the sale" do
        written = File.read(@log_path)
        written.should == "cola\n"
      end
    end
    context "when you buy beer" do
      before(:each) do
        lambda { @nanomart.sell_me(:beer)          }.should raise_error        
      end
      
      it "should log unauthorized sale attempt" do
        written = File.read(@log_path)
        written.should == "WARNING: a 9 year old attempted to buy beer\n"
      end
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @log_path = Tempfile.new("test").path
      @nanomart = Nanomart.new(@log_path, Age19.new)
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

    context "when you buy beer" do
      before(:each) do
        lambda { @nanomart.sell_me(:beer)          }.should raise_error        
      end
      
      it "should log unauthorized sale attempt" do
        written = File.read(@log_path)
        written.should == "WARNING: a 19 year old attempted to buy beer\n"
      end
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


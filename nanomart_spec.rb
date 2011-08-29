require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'
require 'tempfile'


describe "making sure the customer is old enough" do
  context "when you're a kid" do
    before(:each) do
      HighlinePrompter.stub(:get_age).and_return(9)
      Log.logfile = '/dev/null'
      @nanomart = Nanomart.new
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
      HighlinePrompter.stub(:get_age).and_return(19)
      Log.logfile = '/dev/null'
      @nanomart = Nanomart.new
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
      HighlinePrompter.stub(:get_age).and_return(99)
      Log.logfile = '/dev/null'
      @nanomart = Nanomart.new
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
      HighlinePrompter.stub(:get_age).and_return(99)
      Log.logfile = '/dev/null'
      @nanomart = Nanomart.new
      Time.stub!(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      lambda { @nanomart.sell_me(:whiskey)       }.should raise_error(Nanomart::NoSale)
    end
  end
end

describe Log do
  it 'should append a line to a logfile' do
    logfile = Tempfile.new("nanomart-test")
    Log.log("This is a test", logfile.path)
    File.read(logfile.path).strip.should == 'This is a test'
  end

  it 'should log the purchase of a product' do
    logfile = Tempfile.new("nanomart-test")

    the_item = Item::Beer.new
    Log.log_purchase(the_item, logfile.path)

    File.read(logfile.path).strip.should == 'Purchased beer'
  end
end

describe Item do
  describe '#log_sale' do
    it 'should call Log.log_purchase' do
      Log.should_receive(:log_purchase)
      Item::CannedHaggis.new.try_purchase(true)
    end
  end
end

describe 'integration' do
  it 'should log the purchase of a canned haggis' do
    logfile = Tempfile.new("nanomart-test")
    Log.logfile = logfile.path
    nanomart = Nanomart.new
    nanomart.sell_me(:canned_haggis)
    File.read(logfile.path).strip.should == 'Purchased canned_haggis'
  end
end

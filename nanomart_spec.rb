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
      @nanomart.sell_me(:cola).should be_true
      @nanomart.sell_me(:canned_haggis).should be_true
    end

    it "stops you from buying anything age-restricted" do
      @nanomart.sell_me(:beer).should be_false
      @nanomart.sell_me(:whiskey).should be_false
      @nanomart.sell_me(:cigarettes).should be_false
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age19.new)
    end

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      @nanomart.sell_me(:cola).should be_true
      @nanomart.sell_me(:canned_haggis).should be_true
      @nanomart.sell_me(:cigarettes).should be_true
    end

    it "stops you from buying anything age-restricted" do
      @nanomart.sell_me(:beer).should be_false
      @nanomart.sell_me(:whiskey).should be_false
    end
  end

  context "when you're an old fogey on Thursday" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age99.new)
      Time.stub(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      @nanomart.sell_me(:cola).should be_true
      @nanomart.sell_me(:canned_haggis).should be_true
      @nanomart.sell_me(:cigarettes).should be_true
      @nanomart.sell_me(:beer).should be_true
      @nanomart.sell_me(:whiskey).should be_true
    end
  end

  context "when you're an old fogey on Sunday" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age99.new)
      Time.stub(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      @nanomart.sell_me(:whiskey).should be_false
    end
  end

  describe "logging a sale" do
    let(:log_file)  { '/tmp/sales.log' }
    before(:each) do
      @nanomart = Nanomart.new(log_file, Age9.new)
    end

    it "logs a successful sale" do
      File.write(log_file, nil)
      @nanomart.sell_me(:cola)
      File.read(log_file).should eq "cola\n"
    end
  end
end


require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'

# religious-based (Muslim) preferences
class ObservantMuslim
  def get_restriction_value() true end

  def preference_type
    :halal
  end
end

class ReformMuslim
  def get_restriction_value() false end

  def preference_type
    :halal
  end
end

# age-based restrictions
class Age9
  def get_restriction_value() 9 end

  def preference_type
    :age
  end
end

class Age19
  def get_restriction_value() 19 end

  def preference_type
    :age
  end
end

class Age99
  def get_restriction_value() 99 end

  def preference_type
    :age
  end
end

describe "helping Muslim customers keep halal" do
  context "when you're following halal" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', [ObservantMuslim.new, Age99.new])
    end

    it "lets you buy cola" do
      lambda { @nanomart.sell_me(:cola)          }.should_not raise_error
    end

    pending "lets you buy beef ribs" do
      lambda { @nanomart.sell_me(:beef_ribs)     }.should_not raise_error
    end

    it "doesn't let you buy liverwurst" do
      lambda { @nanomart.sell_me(:liverwurst)     }.should raise_error(Nanomart::NoSale)
    end
  end
end

describe "making sure the customer is old enough" do
  context "when you're a kid" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', [Age9.new])
    end

    it "lets you buy cola" do
      lambda { @nanomart.sell_me(:cola)          }.should_not raise_error
    end

    it "lets you buy canned haggis" do
      lambda { @nanomart.sell_me(:canned_haggis) }.should_not raise_error
    end

    it "stops you from buying beer, which is age-restricted" do
      lambda { @nanomart.sell_me(:beer)       }.should raise_error(Nanomart::NoSale)
    end

    it "stops you from buying whiskey, which is age-restricted" do
      lambda { @nanomart.sell_me(:whiskey)    }.should raise_error(Nanomart::NoSale)
    end

    it "stops you from buying smokes, which are age-restricted" do
      lambda { @nanomart.sell_me(:cigarettes) }.should raise_error(Nanomart::NoSale)
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', [Age19.new])
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
      @nanomart = Nanomart.new('/dev/null', [Age99.new])
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
      @nanomart = Nanomart.new('/dev/null', [Age99.new])
      Time.stub!(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      lambda { @nanomart.sell_me(:whiskey)       }.should raise_error(Nanomart::NoSale)
    end
  end
end

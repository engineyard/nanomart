require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'nanomart'

describe "making sure the customer is old enough" do
  let(:age) { raise 'need to provide an age' }
  let(:age_provider) do
    double('age_provider', get_age: age)
  end

  let(:nanomart) do
    Nanomart.new('/dev/null')
  end

  def sell(thing)
    nanomart.sell_me(thing, age_provider)
  end

  context "when you're a kid" do
    let(:age) { 9 }

    it "lets you buy cola and canned haggis" do
      lambda { sell(:cola)          }.should_not raise_error
      lambda { sell(:canned_haggis) }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { sell(:beer)       }.should raise_error(Nanomart::NoSale)
      lambda { sell(:whiskey)    }.should raise_error(Nanomart::NoSale)
      lambda { sell(:cigarettes) }.should raise_error(Nanomart::NoSale)
    end
  end

  context "when you're a newly-minted adult" do
    let(:age) { 19 }

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      lambda { sell(:cola)          }.should_not raise_error
      lambda { sell(:canned_haggis) }.should_not raise_error
      lambda { sell(:cigarettes)    }.should_not raise_error
    end

    it "stops you from buying anything age-restricted" do
      lambda { sell(:beer)       }.should raise_error(Nanomart::NoSale)
      lambda { sell(:whiskey)    }.should raise_error(Nanomart::NoSale)
    end
  end

  context "when you're an old fogey on Thursday" do
    let(:age) { 99 }

    before(:each) do
      Time.stub(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      lambda { sell(:cola)          }.should_not raise_error
      lambda { sell(:canned_haggis) }.should_not raise_error
      lambda { sell(:cigarettes)    }.should_not raise_error
      lambda { sell(:beer)          }.should_not raise_error
      lambda { sell(:whiskey)       }.should_not raise_error
    end
  end

  context "when you're an old fogey on Sunday" do
    let(:age) { 99 }

    before(:each) do
      Time.stub(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      lambda { sell(:whiskey)       }.should raise_error(Nanomart::NoSale)
    end
  end
end

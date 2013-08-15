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
      expect(sell(:cola)).to be_true
      expect(sell(:canned_haggis)).to be_true
    end

    it "stops you from buying anything age-restricted" do
      expect(sell(:beer)).to be_false
      expect(sell(:whiskey)).to be_false
      expect(sell(:cigarettes)).to be_false
    end
  end

  context "when you're a newly-minted adult" do
    let(:age) { 19 }

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      expect(sell(:cola)).to be_true
      expect(sell(:canned_haggis)).to be_true
      expect(sell(:cigarettes)).to be_true
    end

    it "stops you from buying anything age-restricted" do
      expect(sell(:beer)).to be_false
      expect(sell(:whiskey)).to be_false
    end
  end

  context "when you're an old fogey on Thursday" do
    let(:age) { 99 }

    before(:each) do
      Time.stub(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      expect(sell(:cola)).to be_true
      expect(sell(:canned_haggis)).to be_true
      expect(sell(:cigarettes)).to be_true
      expect(sell(:beer)).to be_true
      expect(sell(:whiskey)).to be_true
    end
  end

  context "when you're an old fogey on Sunday" do
    let(:age) { 99 }

    before(:each) do
      Time.stub(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      expect(sell(:whiskey)).to be_false
    end
  end
end

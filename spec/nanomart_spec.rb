require 'spec_helper'

describe "a purcahse" do
  context "on a wednesday" do
    let(:purchase_date) { Time.utc(2012, 11, 27) }
    context "when the customer is 9" do
      let(:customer) { Nanomart::Customer.new(age: 9) }

      it "allows cola and canned haggis" do
        customer.purchase(:cola, on: purchase_date).should be_successful
        customer.purchase(:canned_haggis, on: purchase_date).should be_successful
      end

      it "prevents anything age-restricted" do
        customer.purchase(:beer, on: purchase_date).should_not be_successful
        customer.purchase(:whiskey, on: purchase_date).should_not be_successful
        customer.purchase(:cigarettes, on: purchase_date).should_not be_successful
      end
    end

    context "when the customer is 19" do
      let(:customer) { Nanomart::Customer.new(age: 19) }

      it "allows cola, canned haggis and cigarettes" do
        customer.purchase(:cola, on: purchase_date).should be_successful
        customer.purchase(:canned_haggis, on: purchase_date).should be_successful
        customer.purchase(:cigarettes, on: purchase_date).should be_successful
      end

      it "prevents anything age-restricted" do
        customer.purchase(:beer, on: purchase_date).should_not be_successful
        customer.purchase(:whiskey, on: purchase_date).should_not be_successful
      end
    end

    context "when then customer is 22" do
      let(:customer) { Nanomart::Customer.new(age: 22) }

      it "allows all items" do
        customer.purchase(:cola, on: purchase_date).should be_successful
        customer.purchase(:canned_haggis, on: purchase_date).should be_successful
        customer.purchase(:cigarettes, on: purchase_date).should be_successful
        customer.purchase(:beer, on: purchase_date).should be_successful
        customer.purchase(:whiskey, on: purchase_date).should be_successful
      end
    end
  end
  context "on a sunday" do
    let(:purchase_date) { Time.utc(2012, 12, 2) }

    context "when then customer is 22" do
      let(:customer) { Nanomart::Customer.new(age: 22) }

      it "allows cola, haggis, cigarettes, beer" do
        customer.purchase(:cola, on: purchase_date).should be_successful
        customer.purchase(:canned_haggis, on: purchase_date).should be_successful
        customer.purchase(:cigarettes, on: purchase_date).should be_successful
        customer.purchase(:beer, on: purchase_date).should be_successful
      end

      it "prevents whiskey" do
        customer.purchase(:whiskey, on: purchase_date).should_not be_successful
      end
    end
  end
end

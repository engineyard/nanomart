require 'rspec'
require './item'

class Age9
  def get_age() 9 end
end

class Age99
  def get_age() 99 end
end

describe Item do
  describe '#can_sell_to?' do
    context 'checking one restriction' do
      let(:item) { Item::Beer.new }
      let(:prompter) { Age9.new }

      it 'returns false' do
        expect(item.can_sell_to?(prompter)).to be_false
      end
    end

    context 'checking mixed restrictions' do
      let(:item) { Item::Whiskey.new }
      let(:prompter) { Age99.new }
      before do
        Time.stub(:now)
          .and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
      end

      it 'returns false' do
        expect(item.can_sell_to?(prompter)).to be_false
      end
    end

  end
end


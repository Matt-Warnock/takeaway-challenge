# frozen_literial_string: true

require 'takeaway'

RSpec.describe TakeAway do
  let(:text_client) { TwilioClient.new }
  let(:takeaway) { described_class.new(menu, text_client) }

  describe '#read_menu' do
    it { expect(takeaway).to respond_to(:read_menu) }

    it 'returns dishes with prices' do

      expect(takeaway.read_menu).to eq(dishes_with_price)
    end
  end

  describe '#add_dish' do
    it { expect(takeaway).to respond_to(:add_dish).with(1).argument }

    it 'raises error unless passed a sting' do
      expect { takeaway.add_dish(1) }.to raise_error 'item off menu required'
    end

    context 'when on menu' do
      let(:spring_roll) { { 'spring roll' => 0.99 } }

      it 'adds dish given to basket' do
        takeaway.add_dish('spring roll')

        expect(takeaway.basket.last).to eq spring_roll
      end

      it 'adds same dish given to basket' do
        takeaway.add_dish('spring roll')
        takeaway.add_dish('spring roll')

        expect(takeaway.basket).to eq [spring_roll, spring_roll]
      end

      it 'adds dish using capital letters to basket' do
        takeaway.add_dish('Spring Roll')

        expect(takeaway.basket.last).to eq spring_roll
      end
    end

    context 'when not on menu' do
      it 'does not add to basket' do
        expect { takeaway.add_dish('not on menu') rescue nil }
        .to_not change { takeaway.basket }
      end

      it 'raises error that item is not on menu' do
        message = 'item not on menu'

        expect { takeaway.add_dish('not on menu') }.to raise_error message
      end
    end
  end

  describe '#basket_items' do
    it 'returns array of items in basket' do
      order_meal

      expect(takeaway.basket_items).to eq(basket_items)
    end

    it 'repesents multiples of same item' do
      takeaway.add_dish('peking duck')
      takeaway.add_dish('spring roll')
      takeaway.add_dish('spring roll')
      expected_array = ['1 x peking duck: £7.99', '2 x spring roll: £1.98']

      expect(takeaway.basket_items).to eq(expected_array)
    end
  end

  describe '#total_price' do
    it 'returns total price of basket items' do
      order_meal
      total_basket_value = 17.96

      expect(takeaway.total_price).to eq("Total: £#{total_basket_value}")
    end
  end

  describe '#send_message' do
    before(:each) do
      time_now = Time.utc(2022, 'jan', 1, 17, 52)
      allow(Time).to receive(:now).and_return(time_now)

      api_stub
    end

    it 'calls the client' do
      takeaway.send_message

      expect(api_stub).to have_been_requested
    end

    it 'returns confirmation text is send' do
      expect(takeaway.send_message)
      .to eq("accepted: #{described_class::TEXT_MESSAGE}18:52")
    end
  end

  def menu
    {
      'spring roll' => 0.99,
      'char sui bun' => 3.99,
      'pork dumpling' => 2.99,
      'peking duck' => 7.99,
      'fu-king fried rice' => 5.99
    }
  end

  def dishes_with_price
    [
      'spring roll: £0.99',
      'char sui bun: £3.99',
      'pork dumpling: £2.99',
      'peking duck: £7.99',
      'fu-king fried rice: £5.99'
    ]
  end

  def order_meal
    takeaway.add_dish('peking duck')
    takeaway.add_dish('pork dumpling')
    takeaway.add_dish('spring roll')
    takeaway.add_dish('fu-king fried rice')
  end

  def basket_items
    [
      '1 x peking duck: £7.99',
      '1 x pork dumpling: £2.99',
      '1 x spring roll: £0.99',
      '1 x fu-king fried rice: £5.99'
    ]
  end

  def api_stub
    message_info = File.open('fixtures/twilio_response.json').read
    api_url = "https://api.twilio.com/2010-04-01/Accounts/account_sid/Messages.json"

    stub = stub_request(:post, api_url)
           .to_return(status: 201, body: message_info)
  end
end

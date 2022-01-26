# frozen_literial_string: true

class TakeAway
  TEXT_MESSAGE = 'Thank you! Your order was placed '\
                 'and will be delivered before '.freeze

  attr_reader :basket

  def initialize(menu, text_client)
    @basket = []
    @menu = menu
    @text_client = text_client
  end

  def read_menu
    menu.map { |key, value| "#{key}: £#{value}" }
  end

  def add_dish(dish)
    check_for_string(dish)
    check_for_dish(dish)

    @basket << menu.select { |key| key == dish.downcase }
  end

  def basket_items
    basket.uniq.map do |dish|
      amount = count_repeated_items(dish)
      "#{amount} x #{dish.keys.first}: £#{total_dish_price(dish, amount)}"
    end
  end

  def total_price
    total = 0
    basket.each { |item| total += item.values.first }
    "Total: £#{total}"
  end

  def send_message
    text_client.send_text(TEXT_MESSAGE + one_hour_from_now)
  end

  private

  attr_reader :menu, :text_client

  def one_hour_from_now
    seconds_in_hour = 3600

    (Time.now + seconds_in_hour).strftime('%R')
  end

  def total_dish_price(dish, amount)
    amount * dish.values.first
  end

  def count_repeated_items(dish)
    basket.count { |item| item == dish }
  end

  def check_for_dish(dish)
    raise 'item not on menu' unless menu.keys.any?(dish.downcase)
  end

  def check_for_string(dish)
    raise 'item off menu required' unless dish.kind_of?(String)
  end
end

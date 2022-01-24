# frozen_literial_string: true

require 'twilio_client'

class TakeAway
  attr_reader :basket

  def initialize(output, menu)
    @basket = []
    @output = output
    @menu = menu
  end

  def read_menu
    output.puts menu.map { |key, value| "#{key}: £#{value}" }
  end

  def add_dish(dish)
    check_for_string(dish)
    check_for_dish(dish)

    @basket << menu.select { |key| key == dish.downcase }
  end

  def check_order
    output.puts basket_items.join("\n")
    output.puts total_price
  end

  def send_message
    (TwilioClient.new).send_text('19:52')
  end

  private

  attr_reader :output, :menu

  def total_price
    total = 0
    basket.each { |item| total += item.values.first }
    "Total: £#{total}"
  end

  def basket_items
    basket.uniq.map do |dish|
      amount = count_repeated_items(dish)
      "#{amount} x #{dish.keys.first}: £#{total_dish_price(dish, amount)}"
    end
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

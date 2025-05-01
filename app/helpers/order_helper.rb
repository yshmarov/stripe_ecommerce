module OrderHelper
  def rating_emojis
    { 1 => "😡", 2 => "☹️", 3 => "😐", 4 => "😊", 5 => "🤩" }
  end

  def order_total_amount(order)
    number_to_currency(order.total_amount / 100.0, unit: currency_code_to_symbol(order.currency))
  end
end

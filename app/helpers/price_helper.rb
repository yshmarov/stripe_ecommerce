module PriceHelper
  def price_label(price)
    number_to_currency(price.stripe_price_object.unit_amount / 100.0, unit: currency_code_to_symbol(price.stripe_price_object.currency))
  end
end

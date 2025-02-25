module ProductHelper
  def price_label(product)
    number_to_currency(product.default_price / 100.0, unit: product.default_currency)
  end
end

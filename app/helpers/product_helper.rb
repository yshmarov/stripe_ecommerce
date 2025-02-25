module ProductHelper
  def price_label(product)
    number_to_currency(product.default_price / 100.0, unit: product.default_currency)
  end

  def marketing_features(product)
    marketing_features = product.stripe_product["marketing_features"]
    marketing_features.map { |feature| feature["name"] }
  end
end

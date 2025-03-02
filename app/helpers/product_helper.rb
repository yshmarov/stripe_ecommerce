module ProductHelper
  def marketing_features(product)
    marketing_features = product.stripe_product["marketing_features"]
    marketing_features.map { |feature| feature["name"] }
  end
end

module ProductHelper
  def marketing_features(product)
    marketing_features = product.stripe_product["marketing_features"]
    return [] if marketing_features.blank?

    marketing_features.map { |feature| feature["name"] }
  end
end

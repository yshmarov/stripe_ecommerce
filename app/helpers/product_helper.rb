module ProductHelper
  def marketing_features(product)
    marketing_features = product.stripe_product["marketing_features"]
    return [] if marketing_features.blank?

    marketing_features.map { |feature| feature["name"] }
  end

  # https://schema.org/Product
  def product_schema_json(product)
    {
      "@context": "https://schema.org",
      "@type": "Product",
      "name": product.name,
      "description": product.stripe_product["description"],
      "image": product.stripe_product["images"].first,
      "sku": product.default_price.stripe_price_id,
      "offers": {
        "@type": "Offer",
        "url": product_url(product),
        "priceCurrency": product.default_price.stripe_price["currency"],
        "price": product.default_price.stripe_price["unit_amount"].to_f / 100,
        "availability": "https://schema.org/InStock"
      }
    }.to_json.html_safe
  end
end

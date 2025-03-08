module ProductHelper
  def marketing_features(product)
    marketing_features = product.stripe_product_object.marketing_features
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
      "url": product_url(product),
      "sku": product.default_price.stripe_price_id,
      # "brand": {
      #   "@type": "Brand",
      #   "name": product.brand_name
      # },
      # "category": "",
      "offers": {
        "@type": "Offer",
        "price": product.default_price.stripe_price["unit_amount"].to_f / 100,
        "priceCurrency": product.default_price.stripe_price["currency"],
        "availability": "InStock",
        "itemCondition": "NewCondition"
      }
      # "aggregateRating": {
      #   "@type": "AggregateRating",
      #   "ratingValue": "5",
      #   "ratingCount": "499"
      # },
      # "review": {
      #   "@type": "Review",
      #   "reviewRating": {
      #     "@type": "Rating",
      #     "ratingValue": "5"
      #   },
      #   "author": {
      #     "@type": "Person",
      #     "name": "Anonymous"
      #   }
      # }
    }.to_json.html_safe
  end
end

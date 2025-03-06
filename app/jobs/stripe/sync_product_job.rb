class Stripe::SyncProductJob < ApplicationJob
  queue_as :default

  def perform(stripe_product_id)
    product = Product.unscoped.find_or_initialize_by(stripe_product_id: stripe_product_id)
    stripe_product = Stripe::Product.retrieve(stripe_product_id)
    product.name = stripe_product.name
    product.stripe_product = stripe_product
    product.save!

    prices = Stripe::Price.list(product: stripe_product_id)
    prices.each do |stripe_price|
      price = Price.unscoped.find_or_initialize_by(stripe_price_id: stripe_price.id)
      price.product = product
      price.stripe_price = stripe_price
      price.save!
    end
  end
end

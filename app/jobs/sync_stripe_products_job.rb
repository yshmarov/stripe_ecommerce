class SyncStripeProductsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Stripe::Product.list(
      expand: [ "data.default_price" ]
    ).each do |stripe_product|
      product = Product.find_or_initialize_by(stripe_product_id: stripe_product.id)
      product.name = stripe_product.name
      product.stripe_product = stripe_product
      product.save!
    end
  end
end

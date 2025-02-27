class SyncStripeProductsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Stripe::Product.list(
      expand: [ "data.default_price" ]
    ).each do |stripe_product|
      product = Product.unscoped.where("stripe_product->>'id' = ?", stripe_product.id).first_or_create
      product.name = stripe_product.name
      product.stripe_product = stripe_product
      product.save!
    end
  end
end

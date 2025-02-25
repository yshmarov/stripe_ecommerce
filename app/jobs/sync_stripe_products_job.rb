class SyncStripeProductsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Stripe::Product.list(
      expand: [ "data.default_price" ]
    ).each do |product|
      Product.where("stripe_product->>'id' = ?", product.id).first_or_create do |p|
        p.name = product.name
        p.stripe_product = product
        p.save!
      end
    end
  end
end

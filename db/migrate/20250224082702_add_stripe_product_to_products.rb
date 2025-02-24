class AddStripeProductToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :stripe_product, :json
  end
end

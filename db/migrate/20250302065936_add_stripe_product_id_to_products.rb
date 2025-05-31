class AddStripeProductIdToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :stripe_product_id, :string
  end
end

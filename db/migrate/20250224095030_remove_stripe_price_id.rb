class RemoveStripePriceId < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :stripe_price_id
  end
end

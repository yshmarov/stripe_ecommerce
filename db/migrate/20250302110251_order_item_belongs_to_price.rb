class OrderItemBelongsToPrice < ActiveRecord::Migration[8.0]
  def change
    remove_column :order_items, :product_id
    add_reference :order_items, :price, null: false, foreign_key: true
  end
end

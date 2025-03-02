class RenamePricesToTotalAmounts < ActiveRecord::Migration[8.0]
  def change
    rename_column :order_items, :price, :unit_amount
    rename_column :order_items, :total_price, :total_amount
    rename_column :orders, :total_price, :total_amount
  end
end

class AddSubtotalAmountToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :subtotal_amount, :bigint, null: false, default: 0

    Order.find_each do |order|
      order.calculate_subtotal_amount
      order.calculate_total_amount
    end
  end
end

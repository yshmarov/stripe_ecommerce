class AddSubtotalAmountToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :subtotal_amount, :bigint, null: false, default: 0

    Order.find_each do |order|
      order.update_column(:subtotal_amount, order.total_amount)
      # calculate new total amount
      next if order.draft?
      next if order.stripe_checkout_session_object.nil?
      order.update_column(:total_amount, order.total_amount + order.stripe_checkout_session_object.total_details.amount_shipping + order.stripe_checkout_session_object.total_details.amount_tax - order.stripe_checkout_session_object.total_details.amount_discount)
    end
  end
end

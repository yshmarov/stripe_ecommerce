class AddStripeCheckoutSessionToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :checkout_session, :json
  end
end

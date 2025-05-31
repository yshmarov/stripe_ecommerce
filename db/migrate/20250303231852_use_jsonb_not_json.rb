class UseJsonbNotJson < ActiveRecord::Migration[8.0]
  def change
    change_column :orders, :checkout_session, :jsonb, using: "checkout_session::jsonb"
    change_column :prices, :stripe_price, :jsonb, using: "stripe_price::jsonb"
    change_column :products, :stripe_product, :jsonb, using: "stripe_product::jsonb"
  end
end

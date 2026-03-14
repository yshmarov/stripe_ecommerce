class AddDeliveryToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :delivery_type, :string, default: "home_delivery", null: false
    add_column :orders, :inpost_point_name, :string
    add_column :orders, :inpost_point_address, :string
  end
end

class AddDeliveryFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :delivery_method, :string
    add_column :orders, :delivery_details, :jsonb, default: {}, null: false
  end
end

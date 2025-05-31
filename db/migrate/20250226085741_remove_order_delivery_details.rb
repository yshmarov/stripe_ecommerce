class RemoveOrderDeliveryDetails < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :delivery_details, :text
  end
end

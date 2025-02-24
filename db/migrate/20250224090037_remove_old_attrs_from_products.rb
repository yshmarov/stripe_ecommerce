class RemoveOldAttrsFromProducts < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :image_url
    remove_column :products, :description
  end
end

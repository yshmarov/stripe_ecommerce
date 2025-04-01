class RemoveUnusedSlugs < ActiveRecord::Migration[8.0]
  def change
    remove_index :order_items, :slug
    remove_column :order_items, :slug

    remove_index :orders, :slug
    remove_column :orders, :slug
  end
end

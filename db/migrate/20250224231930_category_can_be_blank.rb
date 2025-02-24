class CategoryCanBeBlank < ActiveRecord::Migration[8.0]
  def change
    change_column_null :products, :category, true
    change_column_default :products, :category, nil
  end
end

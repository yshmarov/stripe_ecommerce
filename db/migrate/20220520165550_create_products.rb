class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.bigint :price
      t.json :stripe_product

      t.timestamps
    end
  end
end

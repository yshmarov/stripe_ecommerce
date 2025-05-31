class CreatePrices < ActiveRecord::Migration[8.0]
  def change
    create_table :prices do |t|
      t.references :product, null: false, foreign_key: true
      t.string :stripe_price_id
      t.json :stripe_price

      t.timestamps
    end
  end
end

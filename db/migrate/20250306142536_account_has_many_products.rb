class AccountHasManyProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :account, foreign_key: true

    Product.find_each do |product|
      product.update(account: Account.first)
    end

    change_column_null :products, :account_id, false
  end
end

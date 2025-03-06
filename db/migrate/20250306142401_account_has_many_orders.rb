class AccountHasManyOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :account, foreign_key: true

    Order.find_each do |order|
      order.update(account: Account.first)
    end

    change_column_null :orders, :account_id, false
  end
end

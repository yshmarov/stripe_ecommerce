class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :stripe_account_id
      t.jsonb :stripe_account

      t.timestamps
    end
  end
end

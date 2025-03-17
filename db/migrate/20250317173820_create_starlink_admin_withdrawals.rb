class CreateStarlinkAdminWithdrawals < ActiveRecord::Migration[7.0]
  def up
    create_table :starlink_admin_withdrawals, id: :uuid do |t|
      t.references :starlink_user_wallet, null: false, type: :uuid, foreign_key: { to_table: :starlink_user_wallets }
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :purpose, null: false
      t.date :withdrawal_date, null: false

      t.timestamps
    end
  end

  def down
    drop_table :starlink_admin_withdrawals
  end
end

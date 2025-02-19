class CreateStarlinkUserWallets < ActiveRecord::Migration[7.0]
  def up
    create_table :starlink_user_wallets, id: :uuid do |t|
      t.references :starlink_user, null: false, foreign_key: true, type: :uuid
      t.string :wallet_id, null: false, limit: 6
      t.decimal :balance, precision: 15, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_index :starlink_user_wallets, :wallet_id, unique: true
  end

  def down
    drop_table :starlink_user_wallets
  end
end

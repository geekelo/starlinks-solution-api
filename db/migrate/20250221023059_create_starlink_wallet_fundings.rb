class CreateStarlinkWalletFundings < ActiveRecord::Migration[7.1]
  def up
    create_table :starlink_wallet_fundings, id: :uuid do |t|
      t.references :starlink_user, null: false, foreign_key: true, type: :uuid
      t.references :starlink_user_wallet, null: false, foreign_key: true, type: :uuid
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :status, null: false, default: "pending"
      t.string :paid, null: false, default: "no"
      t.string :reference, null: false
      t.string :payment_method, null: false # e.g., 'credit_card', 'bank_transfer', etc.
      t.string :transaction_id, null: false

      t.timestamps
    end

    # Add unique indexes separately
    add_index :starlink_wallet_fundings, :reference, unique: true
    add_index :starlink_wallet_fundings, :transaction_id, unique: true
  end

  def down
    drop_table :starlink_wallet_fundings
  end
end


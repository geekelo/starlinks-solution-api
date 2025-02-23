class CreateStarlinkKitRenewals < ActiveRecord::Migration[7.1]
  def up
    create_table :starlink_kit_renewals, id: :uuid do |t|
      t.datetime :deadline, null: false

      # Foreign Keys
      t.uuid :starlink_kit_id, null: false, foreign_key: true
      t.uuid :starlink_user_wallet_id, null: false, foreign_key: true
      t.uuid :starlink_user_id, null: false, foreign_key: true

      # Attributes
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :status, default: 'invoice'
      t.boolean :credit_admin, default: false
      t.integer :month, null: false
      t.integer :year, null: false
      t.date :date_of_renewal, null: true

      t.timestamps
    end

    # Add foreign key constraints
    add_foreign_key :starlink_kit_renewals, :starlink_kits, column: :kit_id
    add_foreign_key :starlink_kit_renewals, :wallets, column: :wallet_id
    add_foreign_key :starlink_kit_renewals, :users, column: :user_id

    # Add indexes for faster lookup
    add_index :starlink_kit_renewals, :kit_id
    add_index :starlink_kit_renewals, :wallet_id
    add_index :starlink_kit_renewals, :user_id
  end

  def down
    remove_foreign_key :starlink_kit_renewals, column: :kit_id
    remove_foreign_key :starlink_kit_renewals, column: :wallet_id
    remove_foreign_key :starlink_kit_renewals, column: :user_id

    drop_table :starlink_kit_renewals
  end
end

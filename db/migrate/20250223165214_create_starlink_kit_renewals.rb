class CreateStarlinkKitRenewals < ActiveRecord::Migration[7.1]
  def up
    create_table :starlink_kit_renewals, id: :uuid do |t|
      t.datetime :deadline, null: false

      # Foreign Keys with references
      t.references :starlink_kit, null: false, type: :uuid, foreign_key: true
      t.references :starlink_user_wallet, null: false, type: :uuid, foreign_key: true
      t.references :starlink_user, null: false, type: :uuid, foreign_key: true

      # Attributes
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :status, default: 'invoice'
      t.boolean :credit_admin, default: false
      t.integer :month, null: false
      t.integer :year, null: false
      t.date :date_of_renewal, null: true

      t.timestamps
    end
  end

  def down
    drop_table :starlink_kit_renewals
  end
end

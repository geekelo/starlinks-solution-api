class CreateStarlinkUsers < ActiveRecord::Migration[7.1]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    
    create_table :starlink_users, id: :uuid do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :phone_number, null: true
      t.string :name, null: false
      t.string :whatsapp_number, null: true
      t.boolean :email_confirmed, default: false
      t.boolean :whatsapp_number_confirmed, default: false
      
      t.timestamps
    end
  end

  def down
    drop_table :starlink_users
  end
end

class AddWhatsappConfirmationToStarlinkUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :starlink_users, :whatsapp_confirmation_token, :string
    add_column :starlink_users, :whatsapp_confirmation_sent_at, :datetime
  end

  def down
    remove_column :starlink_users, :whatsapp_confirmation_token
    remove_column :starlink_users, :whatsapp_confirmation_sent_at
  end
end

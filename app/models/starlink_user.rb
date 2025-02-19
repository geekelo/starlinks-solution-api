class StarlinkUser < ApplicationRecord
  has_secure_password

  # include Api::V1::EmailConfirmationsHelper
  include Api::V1::PasswordResetsHelper
  include Api::V1::WhatsappConfirmationsHelper

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex(20)
    self.confirmation_sent_at = Time.current
  
    if save
      Rails.logger.info "Confirmation token saved: #{confirmation_token}"
      confirmation_token # Return the token
    else
      Rails.logger.error "Failed to save confirmation token: #{errors.full_messages}"
      nil
    end
  end
  

  def confirmation_token_valid?
    confirmation_sent_at && confirmation_sent_at > 2.hours.ago
  end

  def confirm_email
    update(email_confirmed: true, confirmation_token: nil, confirmation_sent_at: nil)
  end

end

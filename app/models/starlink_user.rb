class StarlinkUser < ApplicationRecord


  # include Api::V1::EmailConfirmationsHelper
  include Api::V1::PasswordResetsHelper
  include Api::V1::WhatsappConfirmationsHelper
  has_secure_password
  before_create :generate_confirmation_token

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
    self.email_confirmed = true
    self.confirmation_token = nil
    self.confirmation_sent_at = nil
    save!
  end

end

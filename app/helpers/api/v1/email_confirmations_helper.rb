module Api::V1::EmailConfirmationsHelper

  def generate_confirmation_token
    confirmation_token = SecureRandom.hex(20)
    confirmation_sent_at = Time.current
  
    if save
      confirmation_token
    else
      Rails.logger.error "Failed to save confirmation token: #{errors.full_messages}"
    end
  end  
  
  def confirmation_token_valid?
    confirmation_sent_at && confirmation_sent_at >= 2.hours.ago
  end

  def confirm_email
    update!(email_confirmed: true, confirmation_token: nil, confirmation_sent_at: nil)
  end
end

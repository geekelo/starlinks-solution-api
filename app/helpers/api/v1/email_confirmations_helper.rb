module Api::V1::EmailConfirmationsHelper

  def generate_confirmation_token
    token = SecureRandom.hex(20) # Generate the token first
    self.update!(
      confirmation_token: token,
      confirmation_sent_at: Time.current
    )
    token
  end
  

  def confirmation_token_valid?
    confirmation_sent_at && confirmation_sent_at >= 2.hours.ago
  end

  def confirm_email
    update!(email_confirmed: true, confirmation_token: nil, confirmation_sent_at: nil)
  end
end

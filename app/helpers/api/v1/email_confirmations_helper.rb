module Api::V1::EmailConfirmationsHelper
  extend ActiveSupport::Concern

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex(20)
    self.confirmation_sent_at = Time.current
    save!  # Save directly when called, but not before create
    confirmation_token
  end

  def confirmation_token_valid?
    confirmation_sent_at && confirmation_sent_at >= 2.hours.ago
  end

  def confirm_email
    update!(email_confirmed: true, confirmation_token: nil, confirmation_sent_at: nil)
  end
end

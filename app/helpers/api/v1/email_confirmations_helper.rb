module Api::V1::EmailConfirmationsHelper
  extend ActiveSupport::Concern

  # included do
  #   before_create :generate_confirmation_token
  # end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex(20)
    self.confirmation_sent_at = Time.current
  end

  def confirmation_token_valid?
    confirmation_sent_at && confirmation_sent_at > 2.hours.ago
  end

  def confirm_user
    update(email_confirmed: true, confirmation_token: nil, confirmation_sent_at: nil)
  end

end

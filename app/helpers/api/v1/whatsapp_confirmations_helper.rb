module Api::V1::WhatsappConfirmationsHelper
  extend ActiveSupport::Concern

  def generate_whatsapp_confirmation_token
    token = rand(100_000..999_999).to_s # Generate 6-digit OTP
    self.update(
      whatsapp_confirmation_token: token,
      whatsapp_confirmation_sent_at: Time.current
    )
    token
  end

  def whatsapp_confirmation_token_valid?
    self.whatsapp_confirmation_sent_at && self.whatsapp_confirmation_sent_at >= 25.minutes.ago
  end

  def confirm_whatsapp_number(submitted_token)
    if whatsapp_confirmation_token_valid? && submitted_token == self.whatsapp_confirmation_token
      self.update(
        whatsapp_number_confirmed: true,
        whatsapp_confirmation_token: nil,
        whatsapp_confirmation_sent_at: nil
      )
      true
    else
      false
    end
  end
end

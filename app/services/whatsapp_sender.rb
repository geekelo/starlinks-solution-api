require 'twilio-ruby'

class WhatsappSender
  def self.send_otp(phone_number, otp)
    client = Twilio::REST::Client.new(
      ENV["TWILIO_ACCOUNT_SID"], 
      ENV["TWILIO_AUTH_TOKEN"]
    )

    message = "Your WhatsApp verification code is: #{otp}"

    client.messages.create(
      from: ENV["TWILIO_WHATSAPP_NUMBER"],  
      to: "whatsapp:#{phone_number}",
      body: message
    )
  rescue StandardError => e
    Rails.logger.error "WhatsApp OTP sending failed: #{e.message}"
  end
end

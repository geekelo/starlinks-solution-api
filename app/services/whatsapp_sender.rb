require 'twilio-ruby'

class WhatsappSender
  def self.send_otp(to, otp)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    message = @client.messages.create(
      from: 'whatsapp:+14155238886', # Twilio Sandbox Number
      to: "whatsapp:#{to}",
      body: "**Starlink Installation Solutions**: Enter this code **#{otp}** on our website to proceed.
        Send **STOP** here on WhatsApp to complete the verification process."
    )

    message.sid
  end
end

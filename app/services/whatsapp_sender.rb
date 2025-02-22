# app/services/whatsapp_sender.rb
require 'twilio-ruby'

class WhatsappSender
  def self.send_otp(to, otp)
    account_sid = ENV.fetch('TWILIO_ACCOUNT_SID')
    auth_token = ENV.fetch('TWILIO_AUTH_TOKEN')
    client = Twilio::REST::Client.new(account_sid, auth_token)

    message = client.messages.create(
      from: 'whatsapp:+14155238886', # Twilio Sandbox Number
      content_sid: ENV.fetch('TWILIO_CONTENT_SID'), # Pre-approved WhatsApp Template SID
      content_variables: "{\"1\":\"#{otp}\"}", # Dynamic OTP in template
      to: "whatsapp:#{to}"
    )

    message.sid
  end
end

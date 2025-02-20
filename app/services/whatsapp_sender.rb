# app/services/whatsapp_sender.rb
require 'twilio-ruby'

class WhatsappSender
  def self.send_otp(to, otp)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    client = Twilio::REST::Client.new(account_sid, auth_token)

    message = client.messages.create(
      from: 'whatsapp:+14155238886', # Twilio Sandbox Number
      content_sid: ENV['TWILIO_CONTENT_SID'], # Pre-approved WhatsApp Template SID
      content_variables: "{\"1\":\"#{otp}\"}", # Dynamic OTP in template
      to: "whatsapp:+2348036140158"
    )

    message.sid
  end
end

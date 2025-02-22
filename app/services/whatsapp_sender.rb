require 'twilio-ruby'

class WhatsappSender
  def self.send_otp(to, otp)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    message = @client.messages.create(
      from: 'whatsapp:+14155238886', # Twilio Sandbox Number
      to: "whatsapp:#{to}",
      body: "From Starlink Installation Solutions: Please send STOP here, then Use the OTP code #{otp} to complete your WhatsApp verification on our website." # Sending OTP directly as message
    )

    message.sid
  end
end

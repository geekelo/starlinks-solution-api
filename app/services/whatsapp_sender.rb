require 'twilio-ruby'

class WhatsappSender
  def self.send_otp(to, otp)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    message = @client.messages.create(
      from: 'whatsapp:+14155238886', # Twilio Sandbox Number
      to: "whatsapp:#{to}",
      body: "Your OTP code is: #{otp}" # Send OTP as a simple message
    )

    message.sid
  end
end

require 'twilio-ruby'

TwilioClient = Twilio::REST::Client.new(
  ENV["TWILIO_ACCOUNT_SID"],
  ENV["TWILIO_AUTH_TOKEN"]
)

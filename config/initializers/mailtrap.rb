# Load the Mailtrap delivery method
require_relative '../../lib/mailtrap_delivery_method'

# Register Mailtrap as a delivery method with settings wrapper
ActionMailer::Base.add_delivery_method :mailtrap, MailtrapDeliveryMethod, {
  # Settings will be passed from environment config
}

# Add class attribute for settings (similar to sendgrid)
ActionMailer::Base.class_attribute :mailtrap_settings, default: {}

# Create a wrapper that passes settings to the delivery method
class MailtrapDeliveryMethodWrapper
  def self.new(settings = {})
    # Merge settings from ActionMailer config with any passed settings
    merged_settings = ActionMailer::Base.mailtrap_settings.merge(settings)
    MailtrapDeliveryMethod.new(merged_settings)
  end
end

# Re-register with the wrapper
ActionMailer::Base.add_delivery_method :mailtrap, MailtrapDeliveryMethodWrapper

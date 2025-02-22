class TestMailer < ApplicationMailer
  default from: 'no-reply@cla.jjrsf.org' # Change this to your desired sender email

  def test_email(email)
    mail(to: email, subject: 'Test Email', body: 'This is a test email.')
  end
end

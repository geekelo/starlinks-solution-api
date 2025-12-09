namespace :mailtrap do
  desc "Test Mailtrap email sending"
  task test: :environment do
    puts "\n" + "="*60
    puts "🧪 Testing Mailtrap Email Delivery"
    puts "="*60
    
    # Check environment variables
    puts "\n📋 Configuration Check:"
    puts "  MAILTRAP_API_TOKEN: #{ENV['MAILTRAP_API_TOKEN'] ? "✅ Set (#{ENV['MAILTRAP_API_TOKEN'][0..10]}...)" : "❌ Not Set"}"
    puts "  MAILTRAP_INBOX_ID:  #{ENV['MAILTRAP_INBOX_ID'] ? "✅ Set (#{ENV['MAILTRAP_INBOX_ID']})" : "❌ Not Set"}"
    puts "  MAILTRAP_FROM_EMAIL: #{ENV['MAILTRAP_FROM_EMAIL'] || 'no-reply@sephcocco.com'}"
    puts "  Environment: #{Rails.env}"
    
    # Check if required variables are set
    unless ENV['MAILTRAP_API_TOKEN']
      puts "\n❌ ERROR: MAILTRAP_API_TOKEN not set"
      puts "Add this to your .env file:"
      puts "MAILTRAP_API_TOKEN=your_token_here"
      exit 1
    end
    
    if Rails.env.development? && !ENV['MAILTRAP_INBOX_ID']
      puts "\n⚠️  WARNING: MAILTRAP_INBOX_ID not set (needed for development/sandbox)"
      puts "Add this to your .env file:"
      puts "MAILTRAP_INBOX_ID=your_inbox_id_here"
    end
    
    # Create test mailer class
    class TestMailer < ApplicationMailer
      def test_email(to_email)
        @timestamp = Time.current
        
        mail(
          to: to_email,
          subject: 'Mailtrap Test Email - Sephcocco',
          body: <<~BODY
            Hello!
            
            This is a test email from Sephcocco API.
            
            Sent at: #{@timestamp}
            Environment: #{Rails.env}
            
            If you're seeing this in your Mailtrap inbox, it means:
            ✅ Mailtrap API is configured correctly
            ✅ Environment variables are set properly
            ✅ Email delivery is working
            
            You can now start sending real emails from your application!
            
            ---
            Sephcocco Team
          BODY
        )
      end
    end
    
    # Send test email
    puts "\n📤 Sending test email..."
    test_email = ENV['TEST_EMAIL'] || 'test@example.com'
    puts "  To: #{test_email}"
    
    begin
      TestMailer.test_email(test_email).deliver_now
      
      puts "\n✅ SUCCESS! Email sent via Mailtrap API"
      puts "\n📬 Check your Mailtrap inbox:"
      puts "  https://mailtrap.io/inboxes"
      
      if Rails.env.development?
        puts "\n💡 Tip: The email won't be sent to the actual recipient."
        puts "   It will only appear in your Mailtrap inbox for testing."
      end
      
      puts "\n" + "="*60
      
    rescue => e
      puts "\n❌ ERROR: Failed to send email"
      puts "\nError message:"
      puts "  #{e.message}"
      puts "\nBacktrace:"
      e.backtrace.first(5).each { |line| puts "  #{line}" }
      puts "\n💡 Troubleshooting:"
      puts "  1. Verify MAILTRAP_API_TOKEN is correct"
      puts "  2. Check internet connection"
      puts "  3. Verify Mailtrap account is active"
      puts "  4. Check logs/development.log for more details"
      puts "\n" + "="*60
      exit 1
    end
  end
  
  desc "Test Mailtrap with HTML email"
  task test_html: :environment do
    puts "\n🧪 Testing Mailtrap with HTML Email\n"
    
    class TestHtmlMailer < ApplicationMailer
      def test_html_email(to_email)
        @timestamp = Time.current
        @test_data = {
          user_name: "Test User",
          action: "Testing HTML Email",
          message: "This is a test HTML email with styling"
        }
        
        mail(
          to: to_email,
          subject: 'HTML Test Email - Sephcocco'
        ) do |format|
          format.html { render inline: <<~HTML
            <!DOCTYPE html>
            <html>
              <head>
                <style>
                  body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
                  .container { max-width: 600px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
                  .header { background: #4CAF50; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
                  .content { padding: 20px; }
                  .button { display: inline-block; padding: 12px 24px; background: #4CAF50; color: white; text-decoration: none; border-radius: 4px; }
                  .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
                </style>
              </head>
              <body>
                <div class="container">
                  <div class="header">
                    <h1>Sephcocco Test Email</h1>
                  </div>
                  <div class="content">
                    <h2>Hello #{@test_data[:user_name]}!</h2>
                    <p><strong>Action:</strong> #{@test_data[:action]}</p>
                    <p>#{@test_data[:message]}</p>
                    <p>Sent at: #{@timestamp}</p>
                    <p style="text-align: center; margin: 30px 0;">
                      <a href="http://localhost:3000" class="button">View Dashboard</a>
                    </p>
                  </div>
                  <div class="footer">
                    <p>&copy; 2025 Sephcocco. All rights reserved.</p>
                  </div>
                </div>
              </body>
            </html>
          HTML
          }
          format.text { render inline: <<~TEXT
            Sephcocco Test Email
            ====================
            
            Hello #{@test_data[:user_name]}!
            
            Action: #{@test_data[:action]}
            #{@test_data[:message]}
            
            Sent at: #{@timestamp}
            
            ---
            © 2025 Sephcocco. All rights reserved.
          TEXT
          }
        end
      end
    end
    
    begin
      test_email = ENV['TEST_EMAIL'] || 'test@example.com'
      TestHtmlMailer.test_html_email(test_email).deliver_now
      
      puts "✅ HTML email sent successfully!"
      puts "📬 Check your Mailtrap inbox: https://mailtrap.io/inboxes"
      
    rescue => e
      puts "❌ Error: #{e.message}"
      exit 1
    end
  end
  
  desc "Check Mailtrap configuration"
  task check: :environment do
    puts "\n🔍 Mailtrap Configuration Check\n"
    puts "="*60
    
    checks = {
      "API Token" => ENV['MAILTRAP_API_TOKEN'],
      "Inbox ID" => ENV['MAILTRAP_INBOX_ID'],
      "From Email" => ENV['MAILTRAP_FROM_EMAIL'],
      "Frontend URL" => ENV['FRONTEND_URL']
    }
    
    all_good = true
    
    checks.each do |key, value|
      status = value ? "✅" : "❌"
      display_value = value || "Not Set"
      puts "#{status} #{key.ljust(20)}: #{display_value}"
      all_good = false unless value
    end
    
    puts "="*60
    
    if all_good
      puts "\n✅ All configuration looks good!"
      puts "\nYou can now test email sending:"
      puts "  rails mailtrap:test"
    else
      puts "\n⚠️  Some configuration is missing"
      puts "\nAdd missing variables to your .env file"
    end
    
    puts "\n"
  end
end

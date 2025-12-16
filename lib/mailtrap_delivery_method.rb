require 'net/http'
require 'json'

class MailtrapDeliveryMethod
  attr_accessor :settings

  def initialize(settings = {})
    @settings = settings
  end

  def deliver!(mail)
    # Debug logging
    Rails.logger.info "MailtrapDeliveryMethod - @settings: #{@settings.inspect}"
    Rails.logger.info "MailtrapDeliveryMethod - ActionMailer::Base.mailtrap_settings: #{ActionMailer::Base.mailtrap_settings.inspect}"
    
    # Support both api_key and api_token for flexibility
    # TEMPORARY: Hardcoded token for testing
    api_token = '0aa4461bd01260d47b5e2057bbd4fb46'
    # Original code (commented out for testing):
    # api_token = (@settings[:api_token] || @settings[:api_key] ||
    #             ActionMailer::Base.mailtrap_settings[:api_token] ||
    #              ActionMailer::Base.mailtrap_settings[:api_key] ||
    #              ENV['MAILTRAP_API_TOKEN']).to_s.strip 

    Rails.logger.info "MailtrapDeliveryMethod - api_token: #{api_token ? api_token[0..10] + '...' : 'nil'}"
    Rails.logger.info "MailtrapDeliveryMethod - api_token length: #{api_token&.length}, bytes: #{api_token&.bytesize}, encoding: #{api_token&.encoding}"
    Rails.logger.info "MailtrapDeliveryMethod - api_token inspect: #{api_token.inspect}"
    
    if api_token.nil? || api_token.empty?
      error_msg = "Mailtrap API token is required. Please set MAILTRAP_API_TOKEN environment variable."
      Rails.logger.error error_msg
      raise error_msg
    end
    
    # Check for non-printable characters
    if api_token.match?(/[^\x20-\x7E]/)
      Rails.logger.warn "MailtrapDeliveryMethod - WARNING: Token contains non-printable characters!"
      Rails.logger.warn "MailtrapDeliveryMethod - Token bytes: #{api_token.bytes.inspect}"
    end

    # Get settings from either direct settings or ActionMailer config
    sandbox = @settings[:sandbox] || ActionMailer::Base.mailtrap_settings[:sandbox]
    inbox_id = @settings[:inbox_id] || ActionMailer::Base.mailtrap_settings[:inbox_id]
    
    # Determine if we're using sandbox or production
    endpoint = if sandbox
      if inbox_id.nil? || inbox_id.empty?
        raise "Mailtrap inbox_id is required for sandbox mode"
      end
      "https://sandbox.api.mailtrap.io/api/send/#{inbox_id}"
    else
      "https://send.api.mailtrap.io/api/send"
    end

    Rails.logger.info "MailtrapDeliveryMethod - Endpoint: #{endpoint}"
    Rails.logger.info "MailtrapDeliveryMethod - Mode: #{sandbox ? 'sandbox' : 'production'}"

    uri = URI(endpoint)
    
    # Build the email payload
    payload = build_payload(mail)
    json_body = payload.to_json

    # Mailtrap auth headers differ between Sandbox and Send (production) APIs:
    # - Sandbox API      -> uses `Api-Token: <token>`
    # - Send API (prod)  -> uses `Authorization: Bearer <token>`
    auth_header_value = if sandbox
      api_token
    else
      "Bearer #{api_token}"
    end

    Rails.logger.info "Sending email via Mailtrap API to: #{mail.to.join(', ')}"
    Rails.logger.info "MailtrapDeliveryMethod - Request URI: #{uri}"
    Rails.logger.info "MailtrapDeliveryMethod - Auth header value: #{auth_header_value[0..20]}..."
    Rails.logger.debug "Mailtrap payload: #{payload.inspect}"
    
    begin
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 30, open_timeout: 30) do |http|
        request = Net::HTTP::Post.new(uri.request_uri)
        
        # Set headers - use add_field to match curl behavior more closely
        if sandbox
          request.add_field('Api-Token', auth_header_value)
          Rails.logger.info "MailtrapDeliveryMethod - Using Api-Token header (sandbox mode)"
        else
          request.add_field('Authorization', auth_header_value)
          Rails.logger.info "MailtrapDeliveryMethod - Authorization header: Bearer #{api_token[0..10]}... (length: #{api_token.length})"
        end
        
        request.add_field('Content-Type', 'application/json')
        request.body = json_body
        
        # Log the exact request details
        Rails.logger.info "MailtrapDeliveryMethod - Request method: #{request.method}"
        Rails.logger.info "MailtrapDeliveryMethod - Request path: #{request.path}"
        Rails.logger.info "MailtrapDeliveryMethod - Request headers before send: #{request.to_hash.inspect}"
        Rails.logger.info "MailtrapDeliveryMethod - Request body length: #{request.body.length} bytes"
        
        http.request(request)
      end
      
      Rails.logger.info "Mailtrap response code: #{response.code}"
      Rails.logger.info "Mailtrap response body: #{response.body}"

      unless response.is_a?(Net::HTTPSuccess)
        # Parse error response for better debugging
        error_body = JSON.parse(response.body) rescue { message: response.body }
        
        error_message = case response.code.to_i
        when 401
          "Mailtrap authentication failed (401 Unauthorized). " \
          "Please verify your API token is correct and is a PRODUCTION token (not sandbox). " \
          "Error: #{error_body['errors']&.join(', ') || error_body['message']}"
        when 403
          "Mailtrap access forbidden (403). Check your API token permissions. " \
          "Error: #{error_body['errors']&.join(', ') || error_body['message']}"
        when 422
          "Mailtrap validation error (422). Check your email payload. " \
          "Error: #{error_body['errors']&.join(', ') || error_body['message']}"
        when 429
          "Mailtrap rate limit exceeded (429). Please try again later."
        else
          "Mailtrap API error (#{response.code}): #{error_body['errors']&.join(', ') || error_body['message'] || response.body}"
        end
        
        Rails.logger.error error_message
        raise error_message
      end

      Rails.logger.info "Email sent successfully via Mailtrap API"
      response
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      error_msg = "Mailtrap API timeout: #{e.message}"
      Rails.logger.error error_msg
      raise error_msg
    rescue StandardError => e
      Rails.logger.error "Mailtrap delivery error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      raise
    end
  end

  private

  def build_payload(mail)
    payload = {
      from: {
        email: mail.from.first,
        name: extract_name_from_email(mail[:from])
      },
      to: mail.to.map { |email| { email: email } },
      subject: mail.subject
    }

    # Add CC if present
    payload[:cc] = mail.cc.map { |email| { email: email } } if mail.cc.present?

    # Add BCC if present
    payload[:bcc] = mail.bcc.map { |email| { email: email } } if mail.bcc.present?

    # Add reply-to if present
    if mail.reply_to.present?
      payload[:reply_to] = {
        email: mail.reply_to.first,
        name: extract_name_from_email(mail[:reply_to])
      }
    end

    # Handle multipart emails (HTML and text)
    if mail.multipart?
      html_part = mail.html_part
      text_part = mail.text_part
      
      payload[:html] = html_part.body.decoded if html_part
      payload[:text] = text_part.body.decoded if text_part
    else
      # Single part email
      if mail.content_type.include?('text/html')
        payload[:html] = mail.body.decoded
      else
        payload[:text] = mail.body.decoded
      end
    end

    # Add attachments if present
    if mail.attachments.present?
      payload[:attachments] = mail.attachments.map do |attachment|
        {
          content: Base64.strict_encode64(attachment.body.decoded),
          filename: attachment.filename,
          type: attachment.content_type,
          disposition: attachment.content_disposition || 'attachment'
        }
      end
    end

    # Add custom headers if present
    if mail.header.fields.any? { |field| field.name.start_with?('X-') }
      payload[:headers] = {}
      mail.header.fields.each do |field|
        if field.name.start_with?('X-')
          payload[:headers][field.name] = field.value
        end
      end
    end

    # Add category for production API
    payload[:category] = @settings[:category] if @settings[:category].present?

    payload
  end

  def extract_name_from_email(address_field)
    return nil unless address_field
    
    if address_field.respond_to?(:display_names)
      address_field.display_names.first
    elsif address_field.respond_to?(:decoded)
      # Try to extract name from "Name <email@example.com>" format
      decoded = address_field.decoded
      match = decoded.match(/^(.+?)\s*<.+>$/)
      match ? match[1].strip.gsub(/["']/, '') : nil
    end
  end
end

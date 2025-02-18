class JsonWebToken
  SECRET_KEY = Rails.application.credentials.dig(:JWT_SECRET_KEY) || ENV['JWT_SECRET_KEY']

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256').first
  rescue JWT::ExpiredSignature
    Rails.logger.error('JWT Decode Error: Token has expired')
    nil
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT Decode Error: #{e.message}")
    nil
  end
end

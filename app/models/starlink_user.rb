class StarlinkUser < ApplicationRecord
  has_secure_password

   # Generates a token for password reset
   def generate_password_reset_token
    token = SecureRandom.hex(10)
    update(
      reset_password_token: token,
      reset_password_sent_at: Time.current
    )
    token
  end

  # Checks if token is valid (expires in 2 hours)
  def password_reset_token_valid?
    reset_password_sent_at && reset_password_sent_at > 2.hours.ago
  end

  # Resets password and clears token
  def reset_password(new_password)
    update(password: new_password, reset_password_token: nil, reset_password_sent_at: nil)
  end
end

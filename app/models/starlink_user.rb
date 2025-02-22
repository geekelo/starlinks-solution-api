class StarlinkUser < ApplicationRecord
  include Api::V1::PasswordResetsHelper
  include Api::V1::WhatsappConfirmationsHelper
  include Api::V1::EmailConfirmationsHelper

  has_secure_password
end

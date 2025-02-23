class StarlinkUser < ApplicationRecord
  include Api::V1::PasswordResetsHelper
  include Api::V1::WhatsappConfirmationsHelper
  include Api::V1::EmailConfirmationsHelper

  has_secure_password
  has_many :starlink_wallet_fundings
end

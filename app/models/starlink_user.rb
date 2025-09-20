class StarlinkUser < ApplicationRecord
  include Api::V1::PasswordResetsHelper
  include Api::V1::WhatsappConfirmationsHelper
  include Api::V1::EmailConfirmationsHelper

  has_secure_password
  has_one :starlink_user_wallet, dependent: :destroy
  has_many :starlink_wallet_fundings, dependent: :destroy
  has_many :starlink_kits, dependent: :destroy
end

class StarlinkUser < ApplicationRecord
  has_secure_password

  include Api::V1::EmailConfirmationsHelper
  include Api::V1::PasswordResetsHelper
   
end

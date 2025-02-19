class StarlinkUser < ApplicationRecord
  has_secure_password

  include EmailConfirmationsHelper
  include PasswordResetsHelper
   
end

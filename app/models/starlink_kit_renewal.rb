# app/models/starlink_kit_renewal.rb
class StarlinkKitRenewal < ApplicationRecord
  belongs_to :starlink_kit
  belongs_to :starlink_user_wallet
  belongs_to :starlink_user

  include Api::V1::RenewalPdfGeneratorHelper
  include Api::V1::StarlinkKitRenewalsHelper
  include Api::V1::StarlinkKitActivationsHelper

end

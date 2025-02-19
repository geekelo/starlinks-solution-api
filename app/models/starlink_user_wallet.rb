class StarlinkUserWallet < ApplicationRecord
  belongs_to :starlink_user

  before_create :generate_wallet_id

  private

  def generate_wallet_id
    self.wallet_id ||= SecureRandom.alphanumeric(6).upcase
  end
end

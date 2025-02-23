class StarlinkWalletFunding < ApplicationRecord
  belongs_to :starlink_user
  belongs_to :starlink_user_wallet

  before_validation :generate_reference, on: :create
  before_validation :generate_transaction_id, on: :create

  private

  def generate_reference
    self.reference ||= SecureRandom.alphanumeric(8).upcase
  end

  def generate_transaction_id
    self.transaction_id ||= "fund-#{SecureRandom.alphanumeric(8).downcase}"
  end
end

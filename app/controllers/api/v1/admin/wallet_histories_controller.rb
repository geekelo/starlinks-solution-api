class Api::V1::Admin::WalletHistoriesController < ApplicationController
  before_action :authenticate_token!

  # GET /api/v1/admin/wallet_history
  def index
    wallet_history = {
      fundings = StarlinkWalletFunding.where(status: 'approved')
      .joins(starlink_user_wallet: :starlink_user) # Ensure proper join path
      .select('starlink_wallet_fundings.id, 
               starlink_wallet_fundings.amount, 
               starlink_wallet_fundings.funding_date, 
               starlink_wallet_fundings.source, 
               starlink_wallet_fundings.created_at, 
               starlink_users.email'),

      renewals: StarlinkKitRenewal.where(status: 'receipt')
                                  .joins(starlink_kit: :starlink_user)
                                  .select('starlink_kit_renewals.id, starlink_kit_renewals.amount, starlink_kit_renewals.date_of_renewal, starlink_kit_renewals.created_at, starlink_kits.kit_number, starlink_users.email AS user_email'),
      
      withdrawals: StarlinkAdminWithdrawal.select(:id, :amount, :purpose, :withdrawal_date, :created_at)
    }

    render json: wallet_history, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def admin_balance
    admin_balance = StarlinkUserWallet.find_by(wallet_id: 'byaste').balance

    render json: { admin_balance: admin_balance }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal
  end
end

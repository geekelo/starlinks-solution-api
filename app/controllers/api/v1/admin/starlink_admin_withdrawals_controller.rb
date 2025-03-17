class Api::V1::Admin::StarlinkAdminWithdrawalsController < ApplicationController
  before_action :authenticate_token!
  before_action :authorize_admin!

  # POST /api/v1/admin/withdrawals
  def create
    admin_wallet = StarlinkUserWallet.find_by(wallet_id: 'byaste')

    if admin_wallet.nil?
      return render json: { error: 'Admin wallet not found.' }, status: :not_found
    end

    amount = params[:amount].to_f
    purpose = params[:purpose]
    withdrawal_date = params[:withdrawal_date] || Date.today

    if amount <= 0
      return render json: { error: 'Invalid withdrawal amount.' }, status: :unprocessable_entity
    end

    if admin_wallet.balance < amount
      return render json: { error: 'Insufficient funds in admin wallet.' }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      # Deduct amount from admin wallet
      admin_wallet.update!(balance: admin_wallet.balance - amount)

      # Record the withdrawal
      withdrawal = StarlinkAdminWithdrawal.create!(
        starlink_user_wallet_id: admin_wallet.id,
        amount: amount,
        purpose: purpose,
        withdrawal_date: withdrawal_date
      )
    end

    render json: { message: 'Withdrawal successful.', new_balance: admin_wallet.balance }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def authorize_admin!
    unless current_user&.role == 'admin'
      render json: { error: 'Unauthorized access.' }, status: :forbidden
    end
  end  
end

class Api::V1::StarlinkActivatesController < ApplicationController
  before_action :authenticate_token!

  def activate_kit
    wallet = find_wallet
    kit = current_user.starlink_kits.find_by(id: params[:kit_id])
    kit_id = kit.id
    kit_plan_id = kit.starlink_plan_id

    return render json: { error: "Wallet not found" }, status: :not_found if wallet.nil?
    return render json: { error: "Kit ID is missing" }, status: :unprocessable_entity if kit_id.blank?

    total_due = StarlinkKitRenewal.total_due(wallet, kit_id, kit_plan_id, kit)


    # Add extra 50,000 if otsp is false
    total_due += 50_000 unless current_user.otsp

    if wallet_has_sufficient_funds?(wallet, total_due)
      process_payment(wallet, total_due)
      StarlinkKitRenewal.create_new_renewal(wallet, kit_plan_id, total_due, kit_id, kit)

      render json: { message: "Kit activated successfully" }, status: :ok
    else
      render json: { error: "Insufficient funds", amount-due: total_due }, status: :unprocessable_entity
    end
  end

  private

  # Find user wallet
  def find_wallet
    current_user&.starlink_user_wallet
  end

  # Check if wallet has enough balance
  def wallet_has_sufficient_funds?(wallet, amount)
    wallet.balance >= amount
  end

  # Process payment, deduct from user and credit admin
  def process_payment(wallet, amount)
    wallet.update!(balance: wallet.balance - amount)
    credit_admin_wallet(amount)
    StarlinkKitRenewal.mark_as_paid(wallet, kit)
    current_user.update!(otsp: true)
  end

  # Credit admin wallet
  def credit_admin_wallet(amount)
    admin_wallet = StarlinkUserWallet.find_by(wallet_id: "byaste")
    admin_wallet.update!(balance: admin_wallet.balance + amount) if admin_wallet
  end
end

class Api::V1::Admin::KitAutorenewsController < ApplicationController
  before_action :authenticate_token!  # or :authenticate_admin!

  def auto_renew_kits
    today = Date.today

    kits = StarlinkKit.includes(:starlink_kit_renewals)
                      .where(status: "active")

    renewed_count = 0
    failed_kits = []

    kits.find_each do |kit|
      invoice = kit.starlink_kit_renewals
                   .where(status: "invoice")
                   .order(deadline: :desc)
                   .first

      next unless kit.auto_renew && invoice && (invoice.deadline - today).to_i <= 7 && today < invoice.deadline

      wallet = kit.starlink_user.starlink_user_wallet
      kit_plan = kit.starlink_plan
      kit_id = kit.id

      success = activate_kit(wallet, kit_plan, kit_id, kit)

      renewed_count += 1 if success
      failed_kits << kit.kit_number unless success
    end

    render json: { message: "Kits auto-renewed", count: renewed_count, failed_kits: failed_kits }, status: :ok
  end

  def renew_specific_kit
    kit = StarlinkKit.find_by(id: params[:id])
    wallet = kit.starlink_user.starlink_user_wallet
    kit_plan = kit.starlink_plan
    kit_id = kit.id
    success = activate_kit(wallet, kit_plan, kit_id, kit)
    if success
      render json: { message: "Kit auto-renewed successfully" }, status: :ok
    else
      render json: { error: "Failed to auto-renew kit" }, status: :unprocessable_entity
    end
  end

  private

  def activate_kit(wallet, kit_plan, kit_id, kit)
    return false if wallet.nil? || kit_id.blank?

    total_due = StarlinkKitRenewal.total_due(wallet, kit_id, kit_plan, kit)
    total_due += 50_000 unless kit.otsp

    if wallet_has_sufficient_funds?(wallet, total_due)
      process_payment(wallet, total_due, kit)
      StarlinkKitRenewal.create_new_renewal(wallet, kit_plan, total_due, kit_id, kit)
      true
    else
      false
    end
  end

  def wallet_has_sufficient_funds?(wallet, amount)
    wallet.balance >= amount
  end

  def process_payment(wallet, amount, kit)
    wallet.update!(balance: wallet.balance - amount)
    credit_admin_wallet(amount)
    StarlinkKitRenewal.mark_as_paid(wallet, kit)
    kit.update!(otsp: true)
  end

  def credit_admin_wallet(amount)
    admin_wallet = StarlinkUserWallet.find_by(wallet_id: "byaste")
    admin_wallet.update!(balance: admin_wallet.balance + amount) if admin_wallet
  end
end

class Api::V1::Admin::KitRenewalsController < ApplicationController
  before_action :authenticate_token!
  before_action :set_kit_renewal, only: [:update]

  # GET /api/v1/admin/kit_renewals
  def index
    if params[:kit_number].present?
      kit = StarlinkKit.find_by(kit_number: params[:kit_number])
  
      if kit.nil?
        return render json: { error: 'Kit not found' }, status: :not_found
      end
  
      kit_renewals = StarlinkKitRenewal
                       .where(starlink_kit_id: kit.id)
                       .select('starlink_kit_renewals.*, starlink_kits.kit_number')
                       .joins(:starlink_kit)
    else
      kit_renewals = StarlinkKitRenewal
                       .select('starlink_kit_renewals.*, starlink_kits.kit_number')
                       .joins(:starlink_kit)
    end
  
    render json: kit_renewals, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end   

  # POST /api/v1/admin/kit_renewals
  def create
    kit = StarlinkKit.find_by(kit_number: params[:kit_number])
  
    unless kit
      return render json: { error: "User kit not found" }, status: :not_found
    end
  
    user = kit.starlink_user
    wallet = user.starlink_user_wallet
    admin_wallet = StarlinkUserWallet.find_by(wallet_id: "byaste")
    amount = params[:kit_renewal][:amount].to_f
  
    if params[:deduct_wallet] == true
      if wallet.balance >= amount
        wallet.update(balance: wallet.balance - amount)
        admin_wallet.update(balance: admin_wallet.balance + amount)
      else
        return render json: { error: "Insufficient wallet balance" }, status: :unprocessable_entity
      end
    end
  
    kit_renewal_params = {
      starlink_user_id: user.id,
      starlink_kit_id: kit.id,
      starlink_user_wallet_id: wallet.id,
      amount: amount,
      start_date: params[:kit_renewal][:start_date],
      end_date: params[:kit_renewal][:end_date],
      month: params[:kit_renewal][:month],
      year: params[:kit_renewal][:year],
      deadline: params[:kit_renewal][:deadline],
      credit_admin: params[:kit_renewal][:credit_admin]
    }

    if params[:status] == "receipt"
      kit_renewal_params[:status] = "receipt"
      kit_renewal_params[:date_of_renewal] = params[:kit_renewal][:date_of_renewal] || Date.today
    else
      kit_renewal_params[:status] = "invoice"
      kit_renewal_params[:credit_admin] = false
    end
  
    kit_renewal = StarlinkKitRenewal.new(kit_renewal_params)
  
    if kit_renewal.save
      render json: { message: "Kit renewal created successfully for #{user.email}", kit_renewal: kit_renewal }, status: :created
    else
      render json: { errors: kit_renewal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/admin/kit_renewals/:id
  def update
    if @kit_renewal.update(kit_renewal_params)
      render json: { message: "Kit renewal updated successfully", kit_renewal: @kit_renewal }, status: :ok
    else
      render json: { errors: @kit_renewal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_kit_renewal
    @kit_renewal = StarlinkKitRenewal.find_by(id: params[:id])

    unless @kit_renewal
      render json: { error: "Kit renewal record not found" }, status: :not_found
    end
  end

  def kit_renewal_params
    params.require(:kit_renewal).permit(:amount, :credit_admin, :start_date, :end_date, :month, :year, :deadline)
  end
end

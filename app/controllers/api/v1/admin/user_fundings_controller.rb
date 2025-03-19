class Api::V1::Admin::UserFundingsController < ApplicationController
  before_action :authenticate_token!
  before_action :set_funding, only: [:update]

  # GET /api/v1/admin/user_fundings
  def index
    if params[:email].present?
      user = StarlinkUser.find_by(email: params[:email])
  
      if user.nil?
        return render json: { error: 'User not found' }, status: :not_found
      end
  
      fundings = StarlinkWalletFunding
                   .joins(starlink_user_wallet: :starlink_user)
                   .where(starlink_users: { id: user.id })
                   .select('starlink_wallet_fundings.*, starlink_users.email AS user_email')
    end
  
    render json: fundings, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
   

  # POST /api/v1/admin/user_fundings
  def create
    user = StarlinkUser.find_by(email: params[:email])

    unless user
      return render json: { error: "User not found" }, status: :not_found
    end

    wallet = user.starlink_user_wallet

    unless wallet
      return render json: { error: "User wallet not found" }, status: :not_found
    end

    funding = StarlinkWalletFunding.new(
      starlink_user_id: user.id,
      starlink_user_wallet_id: wallet.id,
      amount: params[:funding][:amount],
      payment_method: params[:funding][:payment_method],
      status: "approved" # Automatically approve since admin is creating it
    )

    if funding.save
      render json: { message: "Funding created successfully for #{user.email}", funding: funding }, status: :created
    else
      render json: { errors: funding.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/admin/user_fundings/:id
  def update
    if @funding.update(funding_params)
      render json: { message: "Funding updated successfully", funding: @funding }, status: :ok
    else
      render json: { errors: @funding.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_funding
    @funding = StarlinkWalletFunding.find_by(id: params[:id])

    unless @funding
      render json: { error: "Funding record not found" }, status: :not_found
    end
  end

  def update_funding_params
    params.require(:funding).permit(:status, :amount, :payment_method)
  end

  def funding_params
    params.require(:funding).permit(:amount, :payment_method, :status)
  end
end

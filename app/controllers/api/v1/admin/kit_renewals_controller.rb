class Api::V1::Admin::KitRenewalsController < ApplicationController
  before_action :authenticate_token!
  before_action :set_kit_renewal, only: [:update]

  # GET /api/v1/admin/kit_renewals
  def index
    user = StarlinkUser.find_by(email: params[:email])
  
    if user.nil?
      return render json: { error: 'User not found' }, status: :not_found
    end
  
    renewals = StarlinkKitRenewal
                 .joins(:starlink_user)
                 .where(starlink_users: { id: user.id })
                 .select('starlink_kit_renewals.*, starlink_users.email AS user_email')
  
    render json: renewals, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end  

  # POST /api/v1/admin/kit_renewals
  def create
    user = StarlinkUser.find_by(email: params[:email])

    unless user
      return render json: { error: "User not found" }, status: :not_found
    end

    kit = user.starlink_kit

    unless kit
      return render json: { error: "User kit not found" }, status: :not_found
    end

    kit_renewal = StarlinkKitRenewal.new(
      starlink_user_id: user.id,
      starlink_kit_id: kit.id,
      amount: params[:kit_renewal][:amount],
      date_of_renewal: params[:kit_renewal][:date_of_renewal] || Date.today,
      status: "receipt" # Automatically set as "receipt"
    )

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
    params.require(:kit_renewal).permit(:amount, :date_of_renewal, :status)
  end
end

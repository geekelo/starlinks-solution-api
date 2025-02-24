class Api::V1::StarlinkKitsController < ApplicationController
  before_action :authenticate_token!

  def index
    user = current_user
    if user
      starlink_kits = StarlinkKit.where(starlink_user_id: user.id)
      if starlink_kits.present?
        render json: starlink_kits, status: :ok
      else
        render json: { message: 'No kits found.' }, status: :ok
      end
    else
      render json: { error: 'User not authenticated.' }, status: :unauthorized
    end
  end  

  def show
    if params[:id].present?
      kit = StarlinkKit.find_by(id: params[:id])
  
      if kit
        render json: { exists: true, message: 'Kit found.', kit: kit }, status: :ok
      else
        render json: { exists: false, message: 'Kit not found.' }, status: :not_found
      end
    else
      render json: { error: 'No kit ID provided.' }, status: :bad_request
    end
  end  

  def create
    starlink_kit = StarlinkKit.new(starlink_kit_params)
  
    if starlink_kit.save
      render json: { message: "Starlink kit created successfully." }, status: :created
    else
      render json: { errors: starlink_kit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    starlink_kit = StarlinkKit.find(params[:id])
    starlink_kit.destroy
  end

  def kit_address_change_request
    starlink_kit = StarlinkKit.find(params[:id])
    if starlink_kit.update(starlink_kit_address_params)
      render json: starlink_kit
    else
      render json: starlink_kit.errors, status: :unprocessable_entity
    end
  end

  def check_kit_number
    kit_number = params[:kit_number]
  
    if kit_number.present? && StarlinkKit.exists?(kit_number: kit_number)
      render json: { exists: true, message: 'Kit number already exists.' }, status: :ok
    else
      render json: { exists: false, message: 'Kit number is available.' }, status: :ok
    end
  end
  
  private

  def all_kits_params
    params.require(:kit_user).permit(:starlink_user_id)
  end

  def starlink_kit_params
    params.require(:starlink_kit).permit(:kit_number, :address, :nin, :company_name, :company_number, :starlink_user_id)
  end

  def starlink_kit_address_params
    params.require(:starlink_kit_address).permit(:address)
  end
end

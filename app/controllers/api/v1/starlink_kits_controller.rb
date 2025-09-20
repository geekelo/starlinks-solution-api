class Api::V1::StarlinkKitsController < ApplicationController
  before_action :authenticate_token!

  def index
    user = current_user
    if user
      # Get user's kits with pagination first (using correct Kaminari syntax)
      starlink_kits = StarlinkKit.where(starlink_user_id: user.id)
                                .includes(:starlink_kit_renewals)
                                .page(params[:page])
                                .per(params[:per_page] || 50)

      # Check and deactivate overdue kits for current page only (performance optimization)
      starlink_kits.each { |kit| check_and_deactivate_kit(kit) }

      if starlink_kits.any?
        render json: { kits: starlink_kits, total_pages: starlink_kits.total_pages, total_count: starlink_kits.total_count }, status: :ok
      else
        render json: { message: 'No kits found.' }, status: :ok
      end
    else
      render json: { error: 'User not authenticated.' }, status: :unauthorized
    end
  end  

  
  def show
    if params[:id].present?
      kit = current_user.starlink_kits.find_by(id: params[:id])
  
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
    starlink_kit = current_user.starlink_kits.new(starlink_kit_params)
  
    if starlink_kit.save
      render json: { message: "Starlink kit created successfully." }, status: :created
    else
      render json: { errors: starlink_kit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    starlink_kit = current_user.starlink_kits.find_by(id: params[:id])
    
    if starlink_kit
      starlink_kit.destroy
      render json: { message: 'Kit deleted successfully.' }, status: :ok
    else
      render json: { error: 'Kit not found or not authorized.' }, status: :not_found
    end
  end

  def kit_address_change_request
    starlink_kit = current_user.starlink_kits.find_by(id: params[:id])
    
    if starlink_kit.nil?
      return render json: { error: 'Kit not found or not authorized.' }, status: :not_found
    end
    
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

  def set_auto_renew
    starlink_kit = current_user.starlink_kits.find_by(id: params[:id])
    if starlink_kit.update(auto_renew: params[:auto_renew])
      render json: { message: 'Auto-renew status updated successfully.' }, status: :ok
    else
      render json: { errors: starlink_kit.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private

  def check_and_deactivate_kit(kit)
    renewal = kit.starlink_kit_renewals
                 .where(status: "invoice")
                 .order(deadline: :desc)
                 .first
  
    if renewal && renewal.deadline < Date.today
      kit.update!(status: 'deactivated')
      renewal.destroy unless renewal.prorated
    end
  end  

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

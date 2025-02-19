class Api::V1::StarlinkKitsController < ApplicationController
  before_action :set_starlink_kit, only: %i[show update destroy]

  def index
    if params[:user_id]
      @starlink_kits = StarlinkKit.where(starlink_user_id: params[:user_id])
    else
      @starlink_kits = StarlinkKit.all
    end
    
    render json: @starlink_kits
  end
  
  def show
    render json: @starlink_kit
  end

  def create
    @starlink_kit = StarlinkKit.new(starlink_kit_params)
  
    if @starlink_kit.save
      render json: @starlink_kit, status: :created
    else
      render json: @starlink_kit.errors, status: :unprocessable_entity
    end
  end
  

  def update
    if @starlink_kit.update(starlink_kit_params)
      render json: @starlink_kit
    else
      render json: @starlink_kit.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @starlink_kit.destroy
  end

  def check_kit_number
    if StarlinkKit.kit_number_exists?(params[:kit_number])
      render json: { exists: true, message: "Kit number already exists." }, status: :ok
    else
      render json: { exists: false, message: "Kit number is available." }, status: :ok
    end
  end
  

  private

  def set_starlink_kit
    @starlink_kit = StarlinkKit.find(params[:id])
  end

  def starlink_kit_params
    params.require(:starlink_kit).permit(:kit_number, :address, :nin, :company_name, :company_number, :status, :service_line_number, :starlink_user_id)
  end
end

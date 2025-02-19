class Api::V1::StarlinkPlansController < ApplicationController
  def index
    plans = StarlinkPlan.all
    render json: plans
  end

  def show
    plan = StarlinkPlan.find(params[:id])
    render json: plan
  end

  def create
    plan = StarlinkPlan.new(plan_params)

    if plan.save
      render json: plan, status: :created
    else
      render json: plan.errors, status: :unprocessable_entity
    end
  end

  def update
    plan = StarlinkPlan.find(params[:id])

    if plan.update(plan_params)
      render json: plan
    else
      render json: plan.errors, status: :unprocessable_entity
    end
  end

  def destroy
    plan = StarlinkPlan.find(params[:id])
    plan.destroy
  end

  private

  def plan_params
    params.require(:starlink_plan).permit(:name, :price, :status)
  end
end

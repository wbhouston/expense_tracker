# frozen_string_literal: true

class OwnersController < ApplicationController
  def index
    @owners = Owner.all.reorder(:name).page(params.fetch(:page, nil))
  end

  def new
    @owner = Owner.new
  end

  def create
    @owner = Owner.new(allowed_params)

    if @owner.save
      redirect_to owners_path
    else
      render :new
    end
  end

  def edit
    @owner = Owner.find(params.fetch(:id))
  end

  def update
    @owner = Owner.find(params.fetch(:id))

    if @owner.update(allowed_params)
      redirect_to owners_path, notice: 'Successfully updated the owner'
    else
      render :edit
    end
  end

  def destroy
    @owner = Owner.find(params.fetch(:id))

    if @owner.destroy
      redirect_to owners_path, notice: 'Successfully destroyed the owner'
    else
      redirect_to owners_path, alert: 'Failed to destroy the owner'
    end
  end

  private

  def allowed_params
    params.require(:owner).permit(
      :default_ownership_percent,
      :name,
    )
  end
end

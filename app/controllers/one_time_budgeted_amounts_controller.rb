#frozen_string_literal: true

class OneTimeBudgetedAmountsController < ApplicationController
  def index
    @year = params.fetch(:year, Date.current.year)
    @budgeted_amounts = BudgetedAmount.where(frequency: :one_time, year: @year).order(month: :asc)
  end

  def new
    @budgeted_amount = BudgetedAmount.new(frequency: :one_time, year: params.fetch(:year))
  end

  def create
    @budgeted_amount = BudgetedAmount.new(allowed_params)

    if @budgeted_amount.save
      redirect_to(one_time_budgeted_amounts_path(year: @budgeted_amount.year))
    else
      render :new
    end
  end

  def edit
    @budgeted_amount = BudgetedAmount.find(params.fetch(:id))
  end

  def update
    @budgeted_amount = BudgetedAmount.find(params.fetch(:id))
    if @budgeted_amount.update(allowed_params)
      redirect_to(one_time_budgeted_amounts_path(year: @budgeted_amount.year))
    else
      render :edit
    end
  end

  def destroy
    budgeted_amount = BudgetedAmount.find(params[:id])
    year = budgeted_amount.year

    if budgeted_amount.destroy
      flash[:notice] = 'One-time budgeted amount successfully destroyed!'
    else
      flash[:alert] = 'Unable to destroy this one-time budgeted amount.'
    end

    redirect_to(one_time_budgeted_amounts_path(year: year))
  end

  private

  def allowed_params
    params.require(:budgeted_amount).permit(
      :account_id,
      :amount,
      :month,
      :year,
    ).merge(frequency: :one_time)
  end
end
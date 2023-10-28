#frozen_string_literal: true

class BudgetsController < ApplicationController
  def index
    @presenter = BudgetIndexPresenter.new(view_context: view_context)
  end

  def edit
    @form_object = BudgetedAmountsForm.new(year: params[:id])
  end

  def update
    @form_object = BudgetedAmountsForm.new(
      budgeted_amounts_attributes: allowed_params.fetch(:budgeted_amounts_attributes, []),
      year: params[:id],
    )

    if @form_object.save
      redirect_to budgets_path
    else
      render :edit
    end
  end

  private

  def allowed_params
    params.require(:budgeted_amounts_form).permit(
      budgeted_amounts_attributes: [
        :account_id,
        :amount,
        :frequency,
        :id,
        :year,
      ]
    )
  end
end
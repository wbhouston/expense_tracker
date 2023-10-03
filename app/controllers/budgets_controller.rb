#frozen_string_literal: true

class BudgetsController < ApplicationController
  def edit
    @form_object = BudgetedAmountsForm.new
  end

  def update
    @form_object = BudgetedAmountsForm.new(
      budgeted_amounts_attributes: allowed_params.fetch(:budgeted_amounts_attributes, [])
    )

    if @form_object.save
      redirect_to transactions_path
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
        :id,
        :year,
      ]
    )
  end
end
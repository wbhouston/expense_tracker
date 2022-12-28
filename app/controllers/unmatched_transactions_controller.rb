# frozen_string_literal: true

class UnmatchedTransactionsController < ApplicationController
  def edit
    @form = ::UnmatchedTransactionsForm.new
  end

  def update
    @form = ::UnmatchedTransactionsForm.new(allowed_params)

    if @form.save
      redirect_to transactions_path, notice: 'Unmatched transactions updated'
    else
      render :edit
    end
  end

  private

  def allowed_params
    params.require(:unmatched_transactions_form).permit(
      transactions: [
        :account_credited_id,
        :account_debited_id,
        :id,
        :note,
        :percent_shared,
      ],
    )
  end
end

#frozen_string_literal: true

class SplitTransactionsController < ApplicationController
  def show
    @parent_transaction = Transaction.find(params[:id])
  end

  def new
    @form_object = SplitTransactionForm.new(
      parent_id: params[:parent_id],
      split_transactions_attributes: {},
    )
  end

  def create
    @form_object = SplitTransactionForm.new(
      parent_id: allowed_params.fetch(:parent_id),
      split_transactions_attributes: allowed_params.fetch(:split_transactions_attributes, {}),
    )

    if @form_object.save
      redirect_to transactions_path
    else
      render :new, status: 422
    end
  end

  private

  def allowed_params
    params.require(:split_transaction_form).permit(
      :parent_id,
      split_transactions_attributes: [
        :account_credited_id,
        :account_debited_id,
        :amount,
        :date,
        :id,
        :memo,
        :note,
        :_destroy,
      ],
    )
  end
end
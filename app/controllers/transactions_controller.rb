# frozen_string_literal: true

class TransactionsController < ApplicationController
  def index
    @transactions = load_transactions
  end

  def destroy
    @transaction = Transaction.find(params.fetch(:id))

    if @transaction.destroy
      redirect_to transactions_path, notice: 'Successfully destroyed the transaction'
    else
      redirect_to transactions_path, alert: 'Failed to destroy the transaction'
    end
  end

  private

  def account_search_param
    params.fetch(:search, {}).fetch(:account_id, nil)
  end

  def load_transactions
    transactions = Transaction.active
    if account_search_param.present?
      transactions = transactions.with_account_id(account_search_param)
    end
    transactions.reorder(date: :desc).page(params.fetch(:page, nil))
  end
end

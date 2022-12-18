# frozen_string_literal: true

class TransactionsController < ApplicationController
  def index
    @transactions = load_transactions
  end

  private

  def account_search_param
    params.fetch(:search, {}).fetch(:account_id, nil)
  end

  def load_transactions
    transactions = Transaction.all
    if account_search_param.present?
      transactions = transactions.with_account_id(account_search_param)
    end
    transactions.reorder(date: :desc).page(params.fetch(:page, nil))
  end
end

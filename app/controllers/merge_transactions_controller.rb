# frozen_string_literal: true

class MergeTransactionsController < ApplicationController
  before_action :load_accounts, only: :new
  before_action :load_form

  def new
  end

  def create
    raise params
    if @form.perform
      redirect_to accounts_path, notice: 'A worker has been created to merge these accounts'
    else
      load_accounts

      render 'new'
    end
  end

  private

  def allowed_params
    params.require(:merge_transactions_form).permit(
      :merge_into_id,
      merge_account_ids: [],
    )
  end

  def load_accounts
    @accounts = Account.all.reorder(:number)
  end

  def load_form
    @form = if params.key?(:merge_transactions_form)
              ::MergeTransactionsForm.new(
              )
            else
              ::MergeTransactionsForm.new(
              )
            end
  end
end

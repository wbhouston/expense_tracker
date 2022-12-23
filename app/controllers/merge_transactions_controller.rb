# frozen_string_literal: true

class MergeTransactionsController < ApplicationController
  before_action :load_accounts, only: :new
  before_action :load_form

  def new
  end

  def create
    if @form.perform
      redirect_to accounts_path, notice: 'Workers have been created to handle these merges'
    else
      load_accounts

      render 'new'
    end
  end

  private

  def allowed_params
    if params.key?(:merge_transactions_form)
      params.require(:merge_transactions_form).permit(
        merges: [
          :merge_id,
          :merge_into_id,
          :merge_or_ignore,
        ],
      )
    else
      {}
    end
  end

  def load_accounts
    @accounts = Account.all.reorder(:number)
  end

  def load_form
    @form = ::MergeTransactionsForm.new(params: allowed_params)
  end
end

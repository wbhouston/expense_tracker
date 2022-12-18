# frozen_string_literal: true

class MergeAccountsController < ApplicationController
  before_action :load_accounts, only: :new
  before_action :load_form

  def new
  end

  def create
    if @form.perform
      redirect_to accounts_path, notice: 'A worker has been created to merge these accounts'
    else
      load_accounts

      render 'new'
    end
  end

  private

  def allowed_params
    params.require(:merge_accounts_form).permit(
      :merge_into_id,
      merge_account_ids: [],
    )
  end

  def load_accounts
    @accounts = Account.all.reorder(:number)
  end

  def load_form
    @form = if params.key?(:merge_accounts_form)
              ::MergeAccountsForm.new(
                merge_account_ids: allowed_params.fetch(:merge_account_ids, []),
                merge_into_id: allowed_params.fetch(:merge_into_id, nil),
              )
            else
              ::MergeAccountsForm.new(
                merge_account_ids: [],
                merge_into_id: nil,
              )
            end
  end
end

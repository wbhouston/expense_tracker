# frozen_string_literal: true

class AccountsController < ApplicationController
  def index
    @accounts = Account.all.reorder([:account_type, :number])
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(allowed_params)

    if @account.save
      redirect_to accounts_path, notice: 'Account created'
    else
      flash.now[:alert] = 'Error creating account'
      render 'new'
    end
  end

  private

  def allowed_params
    params.require(:account).permit(:name, :number, :account_type)
  end
end

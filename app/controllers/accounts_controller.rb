# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :load_account, only: [:edit, :update, :destroy]

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

  def edit; end

  def update
    if @account.update(allowed_params)
      redirect_to accounts_path, notice: 'Successfully updated account'
    else
      render :edit
    end
  end

  def destroy
    if @account.destroy
      redirect_to accounts_path, notice: 'Successfully removed account'
    else
      redirect_to accounts_path, notice: 'Failed to remove account'
    end
  end

  private

  def allowed_params
    params.require(:account).permit(:name, :number, :account_type)
  end

  def load_account
    @account = Account.find(params.fetch(:id))
  end
end

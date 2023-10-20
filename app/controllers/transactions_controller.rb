# frozen_string_literal: true

class TransactionsController < ApplicationController
  def index
    @transactions = load_transactions
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(allowed_params)

    if @transaction.save
      ::Cache::TransactionYearRange.bust_cache
      redirect_to transactions_path
    else
      render :new
    end
  end

  def edit
    @transaction = Transaction.find(params.fetch(:id))
  end

  def update
    @transaction = Transaction.find(params.fetch(:id))

    if @transaction.update(allowed_params)
      ::Cache::TransactionYearRange.bust_cache
      respond_to do |format|
        format.html do
          redirect_to(
            transactions_path(page: params.fetch(:page, nil)),
            notice: 'Successfully updated the transaction',
          )
        end

        format.turbo_stream do
          redirect_to(transaction_path(@transaction))
        end
      end
    else
      render :edit
    end
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

  def allowed_params
    params.require(:transaction).permit(
      :account_credited_id,
      :account_debited_id,
      :amount,
      :date,
      :memo,
      :note,
      :percent_shared,
    )
  end

  def load_transactions
    transactions = Transaction.base_transactions.where(status: [:active, :split])
    if account_search_param.present?
      transactions = transactions.with_account_id(account_search_param)
    end
    transactions.reorder(date: :desc, id: :desc).page(params.fetch(:page, nil)).per(50)
  end
end

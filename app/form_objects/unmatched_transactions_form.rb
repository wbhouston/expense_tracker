# frozen_string_literal: true

class UnmatchedTransactionsForm
  include ::ActiveModel::Model

  validate :updated_transactions_are_valid

  def initialize(params = {})
    super(params)
  end

  def save
    if valid?
      Transaction.transaction do
        unmatched_transactions.each do |id, transaction|
          transaction.save!
        end
      end
      true
    else
      false
    end
  end

  def accounts
    @accounts ||= Account.all.order_by_number
  end

  def unmatched_transactions
    @unmatched_transactions ||= Transaction.with_account_missing.to_h do |transaction|
      [transaction.id, transaction]
    end
  end

  def transactions=(params)
    params.each do |transaction|
      unmatched_transactions[transaction.fetch(:id).to_i].assign_attributes(
        account_credited_id: transaction.fetch(:account_credited_id),
        account_debited_id: transaction.fetch(:account_debited_id),
        amount: transaction.fetch(:amount).to_d,
        date: transaction.fetch(:date),
        memo: transaction.fetch(:memo),
        note: transaction.fetch(:note),
        percent_shared: transaction.fetch(:percent_shared).to_i,
      )
    end
  end

  private

  def updated_transactions_are_valid
    all_valid = true

    unmatched_transactions.each do |id, transaction|
      all_valid = transaction.valid? && all_valid
    end

    errors.add(:base, 'One or more transaction is invalid') unless all_valid
  end
end

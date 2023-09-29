#frozen_string_literal: true

class SplitTransactionForm
  include ::ActiveModel::Model

  attr_accessor :parent_id

  def initialize(parent_id:, split_transactions_attributes:)
    @parent_id = parent_id
    parent_transaction.status = 'split'

    if split_transactions_attributes.present?
      parent_transaction.assign_attributes(
        split_transactions_attributes: split_transactions_attributes,
      )
    else
      parent_transaction.split_transactions.build
    end
  end

  def parent_transaction
    @parent_transaction ||= ::Transaction.find(parent_id)
  end

  def split_transactions
    @split_transactions ||= parent_transaction.split_transactions
  end

  def save
    if parent_transaction.valid? && sums_valid?
      parent_transaction.save!
      ::Cache::TransactionYearRange.bust_cache
      return true
    else
      return false
    end
  end

  private

  def sums_valid?
    parent_transaction.
      split_transactions.
      reject { |t| t._destroy }.
      map(&:amount).
      sum.
      eql?(parent_transaction.amount)
  end
end
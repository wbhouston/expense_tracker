# frozen_string_literal: true

class MergeTransactionsForm
  include ::ActiveModel::Model

  attr_reader :merge_or_ignore

  def initialize
  end

  def perform
    if valid?
      true
    else
      false
    end
  end

  def suggested_merges
    @suggested_merges ||= Transaction.
      select(
        'transactions.*,' \
        'matched_transactions.id as matched_id,' \
        'matched_transactions.date as matched_date,' \
        'matched_transactions.note as matched_note,' \
        'matched_transactions.memo as matched_memo' \
      ).
      from('transactions, transactions as matched_transactions').
      where('transactions.id > matched_transactions.id').
      where('transactions.account_credited_id = matched_transactions.account_credited_id').
      where('transactions.account_debited_id = matched_transactions.account_debited_id').
      where('transactions.amount = matched_transactions.amount').
      where('transactions.date - matched_transactions.date <= 3').
      where('transactions.date - matched_transactions.date >= -3')
  end
end

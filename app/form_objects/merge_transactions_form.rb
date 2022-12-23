# frozen_string_literal: true

class MergeTransactionsForm
  include ::ActiveModel::Model

  # Dummy variable for simple form
  attr_reader :merge_or_ignore

  attr_reader :merges

  validate :presence_of_both_ids_per_merge

  def initialize(params:)
    merges = []
    super(params)
  end

  def perform
    if valid?
      merges.each do |merge|
        ::Services::MergeTransactionsWorker.perform_async(
          merge.fetch(:merge_into_id),
          merge.fetch(:merge_id),
        )
      end

      true
    else
      false
    end
  end

  def merges=(merge_params)
    @merges = merge_params.select { |merge| merge[:merge_or_ignore] == 'merge' }
  end

  def suggested_merges
    @suggested_merges ||= Transaction.
      from([transactions, matched_transactions]).
      select(
        transactions[Arel.star],
        matched_transactions[:id].as('matched_id'),
        matched_transactions[:date].as('matched_date'),
        matched_transactions[:note].as('matched_note'),
        matched_transactions[:memo].as('matched_memo'),
      ).
      where(Transaction.arel_active).
      where(matched_transactions[:status].eq('active')).
      where(transactions[:id].gt(matched_transactions[:id])).
      where(transactions[:account_credited_id].eq(matched_transactions[:account_credited_id])).
      where(transactions[:account_debited_id].eq(matched_transactions[:account_debited_id])).
      where(transactions[:amount].eq(matched_transactions[:amount])).
      where((transactions[:date] - matched_transactions[:date]).between(-3..3)).
      reorder(transactions[:date].desc)
  end

  private

  def matched_transactions
    @matched_transactions ||= begin
                                t = Transaction.arel_table.dup
                                t.table_alias = :matched_transactions
                                t
                              end
  end

  def presence_of_both_ids_per_merge
    merges.each do |merge|
      if merge[:merge_id].blank? || merge[:merge_into_id].blank?
        errors.add(:base, 'One or more merge row is missing transaction ids')
      end
    end
  end

  def transactions
    transactions ||= Transaction.arel_table
  end
end

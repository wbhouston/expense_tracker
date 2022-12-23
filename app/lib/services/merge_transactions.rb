# frozen_string_literal: true

module Services
  class MergeTransactions
    attr_reader :merge_into_transaction, :merge_transaction

    def initialize(merge_into_transaction:, merge_transaction:)
      @merge_into_transaction = merge_into_transaction
      @merge_transaction = merge_transaction
    end

    def perform!
      Transaction.transaction do
        merge_transaction.becomes!(MergedTransaction)
        merge_transaction.parent_id = merge_into_transaction.id
        merge_transaction.save!
      end
    end
  end
end

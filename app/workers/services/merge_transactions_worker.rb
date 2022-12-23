# frozen_string_literal: true

module Services
  class MergeTransactionsWorker
    include ::Sidekiq::Worker

    def perform(merge_into_transaction_id, merge_transaction_id)
      merge_into_transaction = Transaction.find(merge_into_transaction_id)
      merge_transaction = Transaction.find(merge_transaction_id)

      ::Services::MergeTransactions.new(
        merge_into_transaction: merge_into_transaction,
        merge_transaction: merge_transaction,
      ).perform!
    end
  end
end

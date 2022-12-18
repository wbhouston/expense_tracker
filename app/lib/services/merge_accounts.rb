# frozen_string_literal: true

module Services
  class MergeAccounts
    attr_reader :merge_account_ids, :merge_into_account

    def initialize(merge_account_ids:, merge_into_account:)
      @merge_account_ids = merge_account_ids
      @merge_into_account = merge_into_account
    end

    def perform
      Transaction.transaction do
        merge_account_ids.each do |merge_account_id|
          account = Account.find(merge_account_id)
          move_transactions(move_from_account: account)
          account.destroy!
        end
      end
    end

    private

    def move_transactions(move_from_account:)
      move_from_account.debit_transactions.each do |transaction|
        transaction.update!(account_debited_id: merge_into_account.id)
      end

      move_from_account.credit_transactions.each do |transaction|
        transaction.update!(account_credited_id: merge_into_account.id)
      end
    end
  end
end

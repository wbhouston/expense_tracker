# frozen_string_literal: true

module Services
  class MergeAccountsWorker
    include ::Sidekiq::Worker

    def perform(merge_into_id, merge_account_ids)
      merge_into_account = Account.find(merge_into_id)

      ::Services::MergeAccounts.new(
        merge_account_ids: merge_account_ids,
        merge_into_account: merge_into_account,
      ).perform
    end
  end
end

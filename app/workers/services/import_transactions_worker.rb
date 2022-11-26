# frozen_string_literal: true

module Services
  class ImportTransactionsWorker
    include ::Sidekiq::Worker

    def perform(import_id)
      ::Services::ImportTransactions.new(import_id).import!
    end
  end
end

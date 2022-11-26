# frozen_string_literal: true

module Services
  class ImportTransactions
    attr_reader :transaction_import

    def initialize(import_id)
      @transaction_import = TransactionImport.find(import_id)
    end

    def import!
      Transaction.transaction do
        extracted_rows.each_with_index do |row, index|
          import_row!(row: row)
        rescue ::Date::Error => e
          Rails.logger.error "Dates error on #{index}"
          fail(e)
        end
      end
    end

    private

    def extracted_rows
      @extracted_rows ||= ::Services::ExtractUnimportedRows.new(
        transaction_import: transaction_import,
      ).extract
    end

    def import_row!(row:)
      Transaction.create!(
        account_credited: row.account_credited,
        account_debited: row.account_debited,
        amount: row.amount.abs,
        date: row.date,
        memo: row.memo,
      )
    end
  end
end

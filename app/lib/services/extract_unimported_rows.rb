# frozen_string_literal: true

module Services
  class ExtractUnimportedRows
    attr_reader :transaction_buffer, :transaction_import

    delegate(
      :column_mappings,
      :importing_account,
      :parsed_csv,
      to: :transaction_import,
    )

    # transaction_buffer is the number of days before/after min/max to search
    def initialize(transaction_import:, transaction_buffer: 3)
      @transaction_buffer = transaction_buffer
      @transaction_import = transaction_import
    end

    def extract
      presented_csv_rows.each do |row|
        matched_transactions = transactions_in_range.where(
          amount: row.amount.abs,
          date: row.date,
        ).where(matching_importing_account_arel)

        extracted_rows << row if matched_transactions.blank?
      end

      extracted_rows
    end

    private

    def all_dates
      @all_dates ||= presented_csv_rows.map { |row| row.date }
    end

    def column_mapping_index(search_value)
      column_mappings.find_index(search_value)
    end

    def matching_importing_account_arel
      transaction_table[:account_credited_id].eq(importing_account).
        or transaction_table[:account_debited_id].eq(importing_account)
    end

    def presented_csv_rows
      @presented_csv_rows ||= parsed_csv.value[1..].map do |row|
        ::TransactionImportRowPresenter.new(
          row: row,
          transaction_import: transaction_import,
        )
      end
    end

    def date_range
      @date_range ||=
        (min_date - transaction_buffer.days)..(max_date + transaction_buffer.days)
    end

    def extracted_rows
      @extracted_rows ||= []
    end

    def max_date
      @max_date ||= all_dates.max
    end

    def min_date
      @min_date ||= all_dates.min
    end

    def transaction_table
      @transaction_table ||= Transaction.arel_table
    end

    def transactions_in_range
      @transactions_in_range ||= Transaction.where(date: date_range)
    end
  end
end

# frozen_string_literal: true

module Reports
  class Assets
    def asset_account_per_month(account:, month:)
      amount = asset_account_rolling_totals[account.id][month]

      amount.zero? ? nil : amount
    end

    def asset_accounts
      @asset_accounts ||= Account.assets.order_by_number
    end

    def liability_account_per_month(account:, month:)
      amount = liability_account_rolling_totals[account.id][month]

      amount.zero? ? nil : amount
    end

    def liability_accounts
      @liability_account ||= Account.liabilities.order_by_number
    end

    private

    def transactions_before_date(account_type:, date:, join_transactions:)
      Account.left_joins(join_transactions).
        select(
          Account.arel_table[:id].as('account_id'),
          Transaction.amount_sum,
        ).
        where(Account.arel_type(eq: account_type)).
        where(Transaction.arel_date.lt(date)).
        where(Transaction.arel_active).
        group(
          Account.arel_table[:id],
        )
    end

    def asset_account_rolling_totals
      @asset_account_per_month ||=
        begin
          beginning_of_year = Date.current.beginning_of_year

          (0..12).inject({}) do |running_totals, month_index|
            debits = transactions_before_date(
              account_type: :asset,
              date: beginning_of_year + month_index.months,
              join_transactions: :debit_transactions,
            ).map { |row| [row.account_id, row.amount_sum] }.to_h

            credits = transactions_before_date(
              account_type: :asset,
              date: beginning_of_year + month_index.months,
              join_transactions: :credit_transactions,
            ).map { |row| [row.account_id, row.amount_sum] }.to_h

            asset_accounts.each do |account|
              running_totals[account.id] ||= {}
              running_totals[account.id][month_index] ||=
                (debits[account.id] || 0) - (credits[account.id] || 0)
            end

            running_totals
          end
        end
    end

    def liability_account_rolling_totals
      @liability_account_rolling_totals ||=
        begin
          beginning_of_year = Date.current.beginning_of_year

          (0..12).inject({}) do |running_totals, month_index|
            credits = transactions_before_date(
              account_type: :liability,
              date: beginning_of_year + month_index.months,
              join_transactions: :credit_transactions,
            ).map { |row| [row.account_id, row.amount_sum] }.to_h

            debits = transactions_before_date(
              account_type: :liability,
              date: beginning_of_year + month_index.months,
              join_transactions: :debit_transactions,
            ).map { |row| [row.account_id, row.amount_sum] }.to_h

            liability_accounts.each do |account|
              running_totals[account.id] ||= {}
              running_totals[account.id][month_index] ||=
                (credits[account.id] || 0) - (debits[account.id] || 0)
            end

            running_totals
          end
        end
    end
  end
end

# frozen_string_literal: true

module Reports
  class ProfitAndLosses
    attr_reader :year

    def initialize(year:)
      @year = year
    end

    def expense(account_id:, month:)
      amount = expense_account_debits.fetch(account_id, {}).fetch(month, 0) -
        expense_account_credits.fetch(account_id, {}).fetch(month, 0)
      amount.zero? ? nil : amount
    end

    def expense_accounts
      @expense_accounts ||= Account.expenses.order_by_number
    end

    def expense_total(account_id:)
      amount = expense_account_debits.fetch(account_id, {}).values.sum -
        expense_account_credits.fetch(account_id, {}).values.sum
      amount.zero? ? nil : amount
    end

    def expense_total_by_month(month:)
      expense_accounts.inject(0) do |sum, account|
        amount = (expense(account_id: account.id, month: month) || 0)
        sum = sum + amount
      end
    end

    def expense_total_all
      expense_accounts.inject(0) do |sum, account|
        sum = sum + (expense_total(account_id: account.id) || 0)
      end
    end

    def revenue(account_id:, month:)
      amount = revenue_account_credits.fetch(account_id, {}).fetch(month, 0) -
        revenue_account_debits.fetch(account_id, {}).fetch(month, 0)
      amount.zero? ? nil : amount
    end

    def revenue_total(account_id:)
      amount = revenue_account_credits.fetch(account_id, {}).values.sum -
        revenue_account_debits.fetch(account_id, {}).values.sum
      amount.zero? ? nil : amount
    end

    def revenue_total_by_month(month:)
      revenue_accounts.inject(0) do |sum, account|
        amount = (revenue(account_id: account.id, month: month) || 0)
        sum = sum + amount
      end
    end

    def revenue_total_all
      revenue_accounts.inject(0) do |sum, account|
        sum = sum + (revenue_total(account_id: account.id) || 0)
      end
    end

    def revenue_accounts
      @revenue_accounts ||= Account.revenues.order_by_number
    end

    private

    def expense_account_credits
      @expense_account_credits ||= Account.expenses.left_joins(:credit_transactions).
        select(
          Account.arel_table[:id].as('account_id'),
          Transaction.amount_sum,
          Transaction.extract_month_from_date.as('month'),
          Transaction.extract_year_from_date.as('year'),
        ).
        where(Transaction.extract_year_from_date.eq(year)).
        where(Transaction.arel_active).
        group(
          Account.arel_table[:id],
          Transaction.extract_month_from_date,
          Transaction.extract_year_from_date,
        ).inject({}) do |hash, row|
          hash[row.account_id] ||= {}
          hash[row.account_id][row.month.to_i] = row.amount_sum
          hash
        end
    end

    def expense_account_debits
      @expense_account_debits ||= Account.expenses.left_joins(:debit_transactions).
        select(
          Account.arel_table[:id].as('account_id'),
          Transaction.amount_sum,
          Transaction.extract_month_from_date.as('month'),
          Transaction.extract_year_from_date.as('year'),
        ).
        where(Transaction.extract_year_from_date.eq(year)).
        where(Transaction.arel_active).
        group(
          Account.arel_table[:id],
          Transaction.extract_month_from_date,
          Transaction.extract_year_from_date,
        ).inject({}) do |hash, row|
          hash[row.account_id] ||= {}
          hash[row.account_id][row.month.to_i] = row.amount_sum
          hash
        end
    end

    def revenue_account_credits
      @revenue_account_credits ||= Account.revenues.left_joins(:credit_transactions).
        select(
          Account.arel_table[:id].as('account_id'),
          Transaction.amount_sum,
          Transaction.extract_month_from_date.as('month'),
          Transaction.extract_year_from_date.as('year'),
        ).
        where(Transaction.extract_year_from_date.eq(year)).
        where(Transaction.arel_active).
        group(
          Account.arel_table[:id],
          Transaction.extract_month_from_date,
          Transaction.extract_year_from_date,
        ).inject({}) do |hash, row|
          hash[row.account_id] ||= {}
          hash[row.account_id][row.month.to_i] = row.amount_sum
          hash
        end
    end

    def revenue_account_debits
      @revenue_account_debits ||= Account.revenues.left_joins(:debit_transactions).
        select(
          Account.arel_table[:id].as('account_id'),
          Transaction.amount_sum,
          Transaction.extract_month_from_date.as('month'),
          Transaction.extract_year_from_date.as('year'),
        ).
        where(Transaction.extract_year_from_date.eq(year)).
        where(Transaction.arel_active).
        group(
          Account.arel_table[:id],
          Transaction.extract_month_from_date,
          Transaction.extract_year_from_date,
        ).inject({}) do |hash, row|
          hash[row.account_id] ||= {}
          hash[row.account_id][row.month.to_i] = row.amount_sum
          hash
        end
    end
  end
end

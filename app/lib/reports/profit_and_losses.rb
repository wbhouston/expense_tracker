# frozen_string_literal: true

module Reports
  class ProfitAndLosses
    attr_reader :view_context, :year

    def initialize(view_context:, year:)
      @view_context = view_context
      @year = year
    end

    def expense(account_id: nil, month: nil)
      amount = expense_amount(account_id: account_id, month: month)
      budgeted = budgeted_expense(account_id: account_id, month: month)
      bg_color = expense_bg_color(amount: amount, budgeted: budgeted)

      view_context.content_tag(
        :div,
        class: bg_color,
        title: over_under(amount: amount, budgeted: budgeted, month: month),
      ) do
        amount.zero? ? nil : view_context.number_to_currency(amount)
      end
    end

    def expense_accounts
      @expense_accounts ||= Account.expenses.order_by_number
    end

    def expense_total_by_month(month:)
      expense_accounts.inject(0) do |sum, account|
        amount = (expense_amount(account_id: account.id, month: month) || 0)
        sum = sum + amount
      end
    end

    def expense_total_all
      expense_accounts.inject(0) do |sum, account|
        sum = sum + (expense_amount(account_id: account.id, month: nil) || 0)
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

    def budgeted_amounts_by_account_id
      @budgeted_amounts_by_account_id ||= BudgetedAmount.where(year: year).
        select(:account_id, :amount).
        map { |budgeted| [budgeted.account_id, budgeted.amount] }.
        to_h
    end

    def budgeted_expense(account_id:, month:)
      if account_id.present?
        budgeted_yearly = budgeted_amounts_by_account_id[account_id] || 0

        if month.present?
          (budgeted_yearly / 12.0).round(2)
        else
          if year.eql? Date.current.year
            (budgeted_yearly * ((Date.current.end_of_month - Date.current.beginning_of_year) / 365)).round(2)
          else
            budgeted_yearly
          end
        end
      else
        budgeted_yearly = budgeted_amounts_by_account_id.values.sum

        if month.present?
          (budgeted_yearly / 12.0).round(2)
        else
          if year.eql? Date.current.year
            (budgeted_yearly * ((Date.current.end_of_month - Date.current.beginning_of_year) / 365)).round(2)
          else
            budgeted_yearly
          end
        end
      end
    end

    def expense_amount(account_id:, month:)
      expense =
        if account_id.present?
          if month.present?
            expense_account_debits.fetch(account_id, {}).fetch(month, 0) -
              expense_account_credits.fetch(account_id, {}).fetch(month, 0)
          else
            expense_account_debits.fetch(account_id, {}).values.sum -
              expense_account_credits.fetch(account_id, {}).values.sum
          end
        else
          if month.present?
            expense_account_debits.values.sum { |debits_by_month| debits_by_month.fetch(month, 0) } -
              expense_account_credits.values.sum { |credits_by_month| credits_by_month.fetch(month, 0) }
          else
            expense_account_debits.values.map(&:values).flatten.sum -
              expense_account_credits.values.map(&:values).flatten.sum
          end
        end

      expense || 0
    end

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

    def expense_bg_color(amount:, budgeted:)
      if amount <= budgeted
        'bg-green-100'
      else
        'bg-red-100'
      end
    end

    def over_under(amount:, budgeted:, month:)
      difference = budgeted - amount
      difference_currency = view_context.number_to_currency(difference.abs)
      budgeted = view_context.number_to_currency(budgeted)

      if (month.blank? && year.eql?(Date.current.year)) || month.eql?(Date.current.month)
        partial_notifier = ' to date'
      end

      spent = difference < 0 ? 'Overspent' : 'Underspent'

      "#{spent} by #{difference_currency} (#{budgeted} budgeted#{partial_notifier})"
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

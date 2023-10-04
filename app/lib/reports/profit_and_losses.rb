# frozen_string_literal: true

module Reports
  class ProfitAndLosses
    attr_reader :view_context, :year

    def initialize(view_context:, year:)
      @view_context = view_context
      @year = year
    end

    def monthly_expense(account_id: nil, month: nil)
      account_id = [account_id].compact.presence || monthly_budgeted_amounts_by_account_id.keys
      month = [month].compact.presence || (1..12)
      amount = expense_amount(account_id: account_id, month: month)
      budgeted = monthly_budgeted_expense(account_id: account_id, month: month)
      bg_color = expense_bg_color(amount: amount, budgeted: budgeted)

      amount_display = view_context.content_tag(
        :div,
        class: bg_color,
        title: over_under(amount: amount, budgeted: budgeted, month: month),
      ) { amount.zero? ? nil : view_context.number_to_currency(amount) }

      unless amount.zero?
        amount_display = amount_display + view_context.content_tag(
          :div,
          class: "#{bg_color} text-xs hidden",
          data: { profit_and_losses_target: 'budgetedAmount' },
        ) { view_context.number_to_currency(budgeted) }
      end

      amount_display
    end

    def monthly_expense_accounts
      @monthly_expense_accounts ||= Account.
        expenses.
        order_by_number.
        where(id: monthly_budgeted_amounts_by_account_id.keys)
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

    def yearly_expense(account_id: nil, month: nil)
      account_id = [account_id].compact.presence || yearly_budgeted_amounts_by_account_id.keys
      month = [month].compact.presence || (1..12)
      amount = expense_amount(account_id: account_id, month: month)
      amount_to_date = expense_amount_to_date(account_id: account_id, month: (1..month.last))
      budgeted = yearly_budgeted_expense(account_id: account_id, month: month)
      bg_color = expense_bg_color(amount: amount_to_date, budgeted: budgeted)

      amount_display = view_context.content_tag(
        :div,
        class: bg_color,
        title: over_under(amount: amount_to_date, budgeted: budgeted, month: month),
      ) { amount.zero? ? nil : view_context.number_to_currency(amount) }

      unless amount.zero?
        amount_display = amount_display + view_context.content_tag(
          :div,
          class: "#{bg_color} text-xs hidden",
          data: { profit_and_losses_target: 'budgetedAmount' },
        ) { view_context.number_to_currency(budgeted) }
      end

      amount_display
    end

    def yearly_expense_accounts
      @yearly_expense_accounts ||= Account.
        expenses.
        order_by_number.
        where(id: yearly_budgeted_amounts_by_account_id.keys)
    end

    private

    def expense_amount(account_id:, month:)
      account_id.inject(0) do |account_sum, id|
        account_sum = month.inject(account_sum) do |month_sum, month|
          month_sum = month_sum +
            expense_account_debits.fetch(id, {}).fetch(month, 0) -
            expense_account_credits.fetch(id, {}).fetch(month, 0)
        end
      end || 0
    end

    def expense_amount_to_date(account_id:, month:)
      account_id.inject(0) do |account_sum, id|
        account_sum = month.inject(account_sum) do |month_sum, month|
          month_sum = month_sum +
            expense_account_debits.fetch(id, {}).fetch(month, 0) -
            expense_account_credits.fetch(id, {}).fetch(month, 0)
        end
      end || 0
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

    def monthly_budgeted_amounts_by_account_id
      @monthly_budgeted_amounts_by_account_id ||= BudgetedAmount.
        where(frequency: :monthly, year: year).
        select(:account_id, :amount).
        map { |budgeted| [budgeted.account_id, budgeted.amount] }.
        to_h
    end

    def monthly_budgeted_expense(account_id:, month:)
      monthly_budget = account_id.inject(0) do |account_sum, id|
          account_sum = month.inject(account_sum) do |month_sum, month|
            month_sum = month_sum + monthly_budgeted_amounts_by_account_id.fetch(id, 0)
          end
        end || 0

      if month.size.eql?(12) && Date.current.year.eql?(year)
        monthly_budget * (Date.current.month / 12.0)
      else
        monthly_budget
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

    def yearly_budgeted_amounts_by_account_id
      @yearly_budgeted_amounts_by_account_id ||= BudgetedAmount.
        where(frequency: :yearly, year: year).
        select(:account_id, :amount).
        map { |budgeted| [budgeted.account_id, budgeted.amount] }.
        to_h
    end

    def yearly_budgeted_expense(account_id:, month:)
      yearly_budget = account_id.inject(0) do |sum, id|
          sum = sum + yearly_budgeted_amounts_by_account_id.fetch(id, 0)
        end || 0
    end
  end
end

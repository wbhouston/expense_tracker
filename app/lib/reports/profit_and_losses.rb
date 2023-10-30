# frozen_string_literal: true

module Reports
  class ProfitAndLosses
    attr_reader :view_context, :year

    def initialize(view_context:, year:)
      @view_context = view_context
      @year = year
    end

    def monthly_expense(account_id: nil, month: nil)
      account_id = [account_id].compact.presence || monthly_expense_accounts.ids
      month = [month].compact.presence || (1..12).to_a
      amount = expense_amount(account_id: account_id, month: month)
      budgeted = monthly_budgeted_amount(account_id: account_id, month: month)

      ::ProfitAndLossMonthlyCellViewObject.new(
        amount: amount,
        budgeted: budgeted,
        month: month,
        view_context: view_context,
        year: year,
      ).render_cell
    end

    def monthly_expense_accounts
      @monthly_expense_accounts ||= Account.
        expenses.
        order_by_number.
        where(id: monthly_budgeted_amounts_by_account_id.keys)
    end

    def monthly_revenue(account_id: nil, month: nil)
      account_id = [account_id].compact.presence || monthly_revenue_accounts.ids
      month = [month].compact.presence || (1..12).to_a
      amount = revenue_amount(account_id: account_id, month: month)
      budgeted = monthly_budgeted_amount(account_id: account_id, month: month)

      ::ProfitAndLossMonthlyCellViewObject.new(
        amount: amount,
        budgeted: budgeted,
        inverse: true,
        month: month,
        view_context: view_context,
        year: year,
      ).render_cell
    end

    def monthly_revenue_accounts
      @monthly_revenue_accounts ||= Account.
        revenues.
        order_by_number.
        where(id: monthly_budgeted_amounts_by_account_id.keys)
    end

    def yearly_expense(account_id: nil, month: nil)
      account_id = [account_id].compact.presence || yearly_expense_accounts.ids
      month = [month].compact.presence || (1..12).to_a
      amount = expense_amount(account_id: account_id, month: month)
      amount_to_date = expense_amount(account_id: account_id, month: (1..month.last).to_a)
      budgeted = yearly_budgeted_amount(account_id: account_id, month: month)

      ::ProfitAndLossYearlyCellViewObject.new(
        amount: amount,
        amount_to_date: amount_to_date,
        budgeted: budgeted,
        month: month,
        view_context: view_context,
        year: year,
      ).render_cell
    end

    def yearly_expense_accounts
      @yearly_expense_accounts ||= Account.
        expenses.
        order_by_number.
        where(id: yearly_budgeted_amounts_by_account_id.keys)
    end

    def yearly_revenue(account_id: nil, month: nil)
      account_id = [account_id].compact.presence || yearly_revenue_accounts.ids
      month = [month].compact.presence || (1..12).to_a
      amount = revenue_amount(account_id: account_id, month: month)
      amount_to_date = revenue_amount(account_id: account_id, month: (1..month.last).to_a)
      budgeted = yearly_budgeted_amount(account_id: account_id, month: month)

      ::ProfitAndLossYearlyCellViewObject.new(
        amount: amount,
        amount_to_date: amount_to_date,
        budgeted: budgeted,
        inverse: true,
        month: month,
        view_context: view_context,
        year: year,
      ).render_cell
    end

    def yearly_revenue_accounts
      @yearly_revenue_accounts ||= Account.
        revenues.
        order_by_number.
        where(id: yearly_budgeted_amounts_by_account_id.keys)
    end

    private

    def account_sums_by_period_facade
      @account_sums_by_period_facade ||= ::AccountSumsByPeriodFacade.new(year: year)
    end

    def expense_amount(account_id:, month:)
      account_sums_by_period_facade.expense_sum(account_id: account_id, month: month)
    end

    def monthly_budgeted_amounts_by_account_id
      @monthly_budgeted_amounts_by_account_id ||= BudgetedAmount.
        joins(:account).
        where(frequency: :monthly, year: year).
        select(:account_id, :amount).
        map { |budgeted| [budgeted.account_id, budgeted.amount] }.
        to_h
    end

    def monthly_budgeted_amount(account_id:, month:)
      monthly_budget = account_id.inject(0) do |account_sum, id|
          account_sum = month.inject(account_sum) do |month_sum, month|
            month_sum = month_sum +
              monthly_budgeted_amounts_by_account_id.fetch(id, 0) +
              one_time_budgeted_amounts.fetch(id, {}).fetch(month, 0)
          end
        end || 0

      monthly_budget
    end

    def one_time_budgeted_amounts
      @one_time_budgeted_amounts ||=
        begin
          built_hash = {}

          BudgetedAmount.
            joins(:account).
            where(frequency: :one_time, year: year).
            select(:account_id, :amount, :month).
            each do |budgeted|
              built_hash[budgeted.account_id] ||= {}
              built_hash[budgeted.account_id][budgeted.month] =
                built_hash[budgeted.account_id][budgeted.month].to_f +
                budgeted.amount
            end

            built_hash
        end
    end

    def revenue_amount(account_id:, month:)
      account_sums_by_period_facade.revenue_sum(account_id: account_id, month: month)
    end

    def yearly_budgeted_amounts_by_account_id
      @yearly_budgeted_amounts_by_account_id ||= BudgetedAmount.
        joins(:account).
        where(frequency: :yearly, year: year).
        select(:account_id, :amount).
        map { |budgeted| [budgeted.account_id, budgeted.amount] }.
        to_h
    end

    def yearly_budgeted_amount(account_id:, month:)
      yearly_budget = account_id.inject(0) do |sum, id|
          one_time_sum = (1..month.last).inject(0) do |month_sum, month|
            month_sum = month_sum + one_time_budgeted_amounts.fetch(id, {}).fetch(month, 0)
          end

          sum = sum + yearly_budgeted_amounts_by_account_id.fetch(id, 0) + one_time_sum
        end || 0
    end
  end
end

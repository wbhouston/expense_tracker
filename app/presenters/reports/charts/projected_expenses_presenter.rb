#frozen_string_literal: true

module Reports
  module Charts
    class ProjectedExpensesPresenter
      def periods
        (1..6).map { |months_from_now| months_from_now.months.from_now.beginning_of_month }
      end

      def projected_monthly_expenses
        expenses = periods.map do |period|
          {
            x: period.iso8601,
            y: monthly_budgeted_amount(month: period.month, year: period.year),
          }
        end

        {
          data: expenses,
          label: 'Monthly Expenses',
        }
      end

      def projected_yearly_expenses
        expenses = periods.map do |period|
          {
            x: period.iso8601,
            y: yearly_budgeted_amount(month: period.month, year: period.year),
          }
        end

        {
          data: expenses,
          label: 'Yearly Expenses',
        }
      end

      def projected_total_expenses
        expenses = periods.sum do |period|
          monthly_budgeted_amount(month: period.month, year: period.year) +
            yearly_budgeted_amount(month: period.month, year: period.year)
        end

        {
          data: [{ x: periods.first.iso8601, y: expenses }],
          label: 'Total For 6 Months',
          type: :bar,
        }
      end

      private

      def account_sums_by_period_facade
        @account_sums_by_period_facade ||= ::AccountSumsByPeriodFacade.new
      end

      def current_date
        @current_date ||= Date.current
      end

      def yearly_expense_amount(month:, year:)
        account_sums_by_period_facade.expense_sum(
          account_id: yearly_expense_account_ids_by_year[year],
          month: month,
          year: year,
        )
      end

      def monthly_budgeted_amount(month:, year:)
        BudgetedAmount.joins(:account).
          where(accounts: { account_type: :expense }).
          where(frequency: :monthly, year: year).
          pluck(:amount).
          sum + one_time_budgeted_expense_amounts(
            account_id: monthly_expense_account_ids_by_year[year],
            month: month,
            year: year,
          )
      end

      def monthly_expense_account_ids_by_year
        @expense_account_ids_by_year ||=
          BudgetedAmount.
            joins(:account).
            where(accounts: { account_type: :expense }).
            where(frequency: :monthly).
            select(:account_id, :year).
            group_by { |budgeted_amount| budgeted_amount.year }.
            transform_values { |v| v.map(&:account_id) }
      end

      def one_time_budgeted_expense_amounts(account_id:, month:, year:)
        BudgetedAmount.joins(:account).
          where(accounts: { id: account_id, account_type: :expense}).
          where(frequency: :one_time, month: month, year: year).
          pluck(:amount).
          sum
      end

      def yearly_budgeted_amount(month:, year:)
        budgeted_amount = BudgetedAmount.joins(:account).
          where(accounts: { account_type: :expense}).
          where(frequency: :yearly, year: year).
          pluck(:amount).
          sum + one_time_budgeted_expense_amounts(
            account_id: yearly_expense_account_ids_by_year[year],
            month: (1..current_date.month).to_a,
            year: year,
          )

        ytd_expenses = yearly_expense_amount(
          month: (1..12).to_a,
          year: year,
        )

        if year.eql? current_date.year
          per_month = (budgeted_amount - ytd_expenses) / (12 - current_date.month + 1)
        else
          per_month = budgeted_amount / 12
        end

        [per_month, 0].compact.max + one_time_budgeted_expense_amounts(
          account_id: yearly_expense_account_ids_by_year[year],
          month: month,
          year: year,
        )
      end

      def yearly_expense_account_ids_by_year
        @yearly_expense_account_ids_by_year ||=
          BudgetedAmount.
            joins(:account).
            where(accounts: { account_type: :expense }).
            where(frequency: :yearly).
            select(:account_id, :year).
            group_by { |budgeted_amount| budgeted_amount.year }.
            transform_values { |v| v.map(&:account_id) }
      end
    end
  end
end
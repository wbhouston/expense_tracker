#frozen_string_literal: true

module Reports
  module Charts
    class CashFlowsPresenter
      def expenses_by_month
        {
          borderColor: '#f87171',
          data: expense_data_by_month,
          fill: {
            above: '#fee2e2',
            below: '#dcfce7',
            target: '-1',
          },
          label: 'Expenses',
        }
      end

      def revenues_by_month
        {
          borderColor: '#4ade80',
          data: revenue_data_by_month,
          label: 'Revenues',
        }
      end

      private

      def account_sums_by_period_facade
        @account_sums_by_period_facade ||= AccountSumsByPeriodFacade.new
      end

      def expense_account_ids
        @expense_account_ids ||= Account.expenses.ids
      end

      def expense_data_by_month
        @expense_data_by_month ||= previous_months(first_month_ago).map do |month_start|
          year = month_start.year
          month = month_start.month

          expenses = account_sums_by_period_facade.expense_sum(
            account_id: expense_account_ids,
            month: month,
            year: year,
          )

          {x: month_start.iso8601, y: expenses}
        end
      end

      def first_month_ago
        @first_month_ago ||= begin
          first_transaction = Transaction.active.select(:date).order(date: :asc).first.date
          current = Date.current
          (current.year * 12 + current.month) -
            (first_transaction.year * 12 + first_transaction.month)
        end
      end

      def previous_months(count)
        (1..count).map { |count| Date.current.beginning_of_month - count.months }.reverse
      end

      def revenue_account_ids
        @revenue_account_ids ||= Account.revenues.ids
      end

      def revenue_data_by_month
        @revenue_data_by_month ||= previous_months(first_month_ago).map do |month_start|
          year = month_start.year
          month = month_start.month

          revenues = account_sums_by_period_facade.revenue_sum(
            account_id: revenue_account_ids,
            month: month,
            year: year,
          )

          { x: month_start.iso8601, y: revenues }
        end
      end
    end
  end
end
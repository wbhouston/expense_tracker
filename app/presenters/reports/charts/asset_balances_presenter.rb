#frozen_string_literal: true

module Reports
  module Charts
    class AssetBalancesPresenter
      def balances_by_month
        @balances_by_month ||= asset_accounts.map { |a| chart_for(a) }.compact
      end

      private

      def account_sums_by_period_facade
        @account_sums_by_period_facade ||= AccountSumsByPeriodFacade.new
      end

      def asset_accounts
        @asset_accounts ||= Account.where(account_type: :asset, ignore_in_charts: false)
      end

      def chart_for(account)
        first_date = [
          account.credit_transactions.order(date: :asc).first&.date,
          account.debit_transactions.order(date: :asc).first&.date,
        ].compact.min

        return nil if first_date.blank?

        balances = previous_months(months_ago(first_date)).inject([]) do |array, month_start|
          year = month_start.year
          month = month_start.month

          change = account_sums_by_period_facade.expense_sum(
            account_id: account.id,
            month: month,
            year: year
          )

          array << {
            x: month_start.iso8601,
            y: (array.last&.fetch(:y) || 0) + (change || 0),
          }

          array
        end

        {
          data: balances,
          label: account.name,
        }
      end

      def months_ago(date)
        current = Date.current
        (current.year * 12 + current.month) - (date.year * 12 + date.month)
      end

      def previous_months(count)
        (0..count).map { |count| Date.current.beginning_of_month - count.months }.reverse
      end
    end
  end
end
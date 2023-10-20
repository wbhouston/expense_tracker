#frozen_string_literal: true

class AccountSumsByPeriodFacade
  def initialize(year: nil)
    @year = year
  end

  def expense_sum(account_id:, month:, year: nil)
    account_id = [account_id].flatten
    month = [month].flatten
    year ||= @year

    account_id.inject(0) do |account_sum, id|
      account_sum = month.inject(account_sum) do |month_sum, month|
        month_sum = month_sum +
          account_debit_sums_hash.fetch(id, {}).fetch(year, {}).fetch(month, 0) -
          account_credit_sums_hash.fetch(id, {}).fetch(year, {}).fetch(month, 0)
      end
    end || 0
  end

  def revenue_sum(account_id:, month:, year: nil)
    account_id = [account_id].flatten
    month = [month].flatten
    year ||= @year

    account_id.inject(0) do |account_sum, id|
      account_sum = month.inject(account_sum) do |month_sum, month|
        month_sum = month_sum +
          account_credit_sums_hash.fetch(id, {}).fetch(year, {}).fetch(month, 0) -
          account_debit_sums_hash.fetch(id, {}).fetch(year, {}).fetch(month, 0)
      end
    end || 0
  end

  private

  def account_credit_sums_hash
    @account_credit_sums_hash ||= ::AccountSumsByMonthQuery.
      new(scope: Account.where(account_type: %i[asset expense revenue])).
      active.
      credit_or_debit(:credit).
      for_year(@year).
      scope.
      inject({}) do |hash, row|
        hash[row.account_id] ||= {}
        hash[row.account_id][row.year.to_i] ||= {}
        hash[row.account_id][row.year.to_i][row.month.to_i] = row.amount_sum
        hash
      end
  end

  def account_debit_sums_hash
    @account_debit_sums_hash ||= ::AccountSumsByMonthQuery.
      new(scope: Account.where(account_type: %i[asset expense revenue])).
      active.
      credit_or_debit(:debit).
      for_year(@year).
      scope.
      inject({}) do |hash, row|
        hash[row.account_id] ||= {}
        hash[row.account_id][row.year.to_i] ||= {}
        hash[row.account_id][row.year.to_i][row.month.to_i] = row.amount_sum
        hash
      end
  end
end
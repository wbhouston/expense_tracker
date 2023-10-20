#frozen_string_literal: true

class BudgetedAmountByPeriodFacade
  def budgeted_for_month(month:, year:)
    monthly_budgeted_difference(
      month: month,
      year: year,
    ) + yearly_budgeted_difference(
      month: month,
      year: year,
    )
  end

  private

  def amount_sums_by_period_facade
    @amount_sums_by_period_facade ||= ::AccountSumsByPeriodFacade.new
  end

  def expense_account_ids
    @expense_account_ids ||= Account.expenses.ids
  end

  def monthly_budgeted_amounts
    @monthly_budgeted_amounts ||= BudgetedAmount.
      joins(:account).
      where(frequency: :monthly).
      inject({}) do |hash, budgeted|
        hash[budgeted.account_id] ||= {}
        hash[budgeted.account_id][budgeted.year] = budgeted.amount
        hash
      end
  end

  def monthly_budgeted_difference(month:, year:)
    revenue_account_ids.sum do |account_id|
      monthly_budgeted_amounts.fetch(account_id, {}).fetch(year, 0)
    end - expense_account_ids.sum do |account_id|
      monthly_budgeted_amounts.fetch(account_id, {}).fetch(year, 0)
    end
  end

  def revenue_account_ids
    @revenue_account_ids ||= Account.revenues.ids
  end

  def yearly_budgeted_amounts
    @yearly_budgeted_amounts ||= BudgetedAmount.
      joins(:account).
      where(frequency: :yearly).
      inject({}) do |hash, budgeted|
        hash[budgeted.account_id] ||= {}
        hash[budgeted.account_id][budgeted.year] = budgeted.amount
        hash
      end
  end

  def yearly_budgeted_difference(month:, year:)
    revenues = revenue_account_ids.sum do |account_id|
      if yearly_budgeted_amounts.fetch(account_id, {}).key?(year)
        budgeted = yearly_budgeted_amounts.fetch(account_id, {}).fetch(year, 0)

        revenues_to_date = amount_sums_by_period_facade.revenue_sum(
          account_id: account_id,
          month: (1..month).to_a,
          year: year,
        )

        budgeted > revenues_to_date ? budgeted - revenues_to_date : 0
      else
        0
      end
    end

    expenses = expense_account_ids.sum do |account_id|
      if yearly_budgeted_amounts.fetch(account_id, {}).key?(year)
        budgeted = yearly_budgeted_amounts.fetch(account_id, {}).fetch(year, 0)

        expenses_to_date = amount_sums_by_period_facade.expense_sum(
          account_id: account_id,
          month: (1..month).to_a,
          year: year,
        )

        budgeted > expenses_to_date ? budgeted - expenses_to_date : 0
      else
        0
      end
    end

    remaining_yearly_difference = revenues - expenses

    if Date.current.year.eql? year
      remaining_yearly_difference / (13 - Date.current.month)
    else
      remaining_yearly_difference / 12
    end
  end
end
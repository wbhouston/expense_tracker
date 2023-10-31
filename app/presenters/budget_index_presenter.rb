#frozen_string_literal: true

class BudgetIndexPresenter
  attr_reader :view_context

  def initialize(view_context:)
    @view_context = view_context
  end

  def budgeted_years
    @years ||= ::Cache::TransactionYearRange.new.range
  end

  def monthly_budget_for_year(year)
    view_context.number_to_currency(
      BudgetedAmount.
        joins(:account).
        where(
          accounts: { account_type: :expense },
          frequency: :monthly,
          year: year
        ).pluck(:amount).sum,
      precision: 0,
    )
  end

  def one_time_budgeted_for_year(year)
    view_context.number_to_currency(
      BudgetedAmount.joins(:account).
        where(frequency: :one_time, year: year).
        where(accounts: { account_type: :expense }).
        pluck(:amount).sum,
      precision: 0,
    )
  end

  def yearly_budget_for_year(year)
    view_context.number_to_currency(
      BudgetedAmount.
        joins(:account).
        where(
          accounts: { account_type: :expense },
          frequency: :yearly,
          year: year
        ).pluck(:amount).sum,
      precision: 0,
    )
  end
end
#frozen_string_literal: true

class AccountSumsByMonthQuery
  attr_reader :scope

  def initialize(scope:)
    @scope = scope.select(
      Account.arel_table[:id].as('account_id'),
      Transaction.amount_sum,
      Transaction.extract_month_from_date.as('month'),
    ).group(
      Account.arel_table[:id],
      Transaction.extract_month_from_date,
    )
  end

  def active
    @scope = @scope.where(Transaction.arel_active)

    self
  end

  def credit_or_debit(type)
    type = :credit unless %i[credit debit].include?(type)
    @scope = @scope.left_joins("#{type}_transactions".to_sym)

    self
  end

  def for_year(year)
    @scope = @scope.
      select(Transaction.extract_year_from_date.as('year')).
      group(Transaction.extract_year_from_date).where(
        Transaction.extract_year_from_date.eq(year),
      )

    self
  end
end
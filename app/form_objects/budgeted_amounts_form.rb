#frozen_string_literal: true

class BudgetedAmountsForm
  include ::ActiveModel::Model

  attr_reader :budgeted_amounts_attributes

  def initialize(budgeted_amounts_attributes: [])
    @budgeted_amounts_attributes = budgeted_amounts_attributes
  end

  def budgeted_amount(account_id, year)
    budgeted_amounts.find_or_initialize_by(account_id: account_id, year: year)
  end

  def expense_accounts
    @expense_accounts ||= Account.expenses.order_by_number
  end

  def save
    BudgetedAmount.transaction do
      budgeted_amounts_attributes.each do |attrs|
        budgeted = BudgetedAmount.find_or_initialize_by(
          account_id: attrs['account_id'],
          year: attrs['year'],
        )
        budgeted.update(amount: attrs['amount'].presence || 0)
      end
    end
  end

  def years
    @years ||= ::Cache::TransactionYearRange.new.range
  end

  private

  def budgeted_amounts
    @budgeted_amounts ||= BudgetedAmount.all
  end
end
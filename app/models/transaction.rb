# frozen_string_literal: e

class Transaction < ApplicationRecord
  belongs_to :account_credited, class_name: 'Account', optional: true
  belongs_to :account_debited, class_name: 'Account', optional: true

  validates(:date, :amount, presence: true)

  scope :with_account_id, -> (account_id) do
    where(
      arel_table[:account_credited_id].eq(account_id).
        or(arel_table[:account_debited_id].eq(account_id)),
    )
  end

  def self.extract_month_from_date
    ::Arel::Nodes::NamedFunction.new(
      'DATE_PART',
      [::Arel::Nodes.build_quoted('MONTH'), arel_table[:date]],
    )
  end

  def self.extract_year_from_date
    ::Arel::Nodes::NamedFunction.new(
      'DATE_PART',
      [::Arel::Nodes.build_quoted('YEAR'), arel_table[:date]],
    )
  end

  def self.amount_sum
    arel_table[:amount].sum.as('amount_sum')
  end
end

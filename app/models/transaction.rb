# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :account_credited, class_name: Account.name, optional: true
  belongs_to :account_debited, class_name: Account.name, optional: true
  belongs_to :parent, class_name: Transaction.name, optional: true

  has_many(
    :children,
    class_name: Transaction.name,
    foreign_key: :parent_id,
  )

  validates(:date, :amount, presence: true)

  scope :active, -> { where(arel_active) }
  scope :base_transactions, -> { where(type: nil) }

  scope :with_account_id, -> (account_id) do
    where(
      arel_account_credited.eq(account_id).
        or(arel_account_debited.eq(account_id)),
    )
  end

  scope :with_account_missing, -> do
    where(arel_account_credited.eq(nil).or(arel_account_debited.eq(nil)))
  end

  def self.arel_active
    arel_table[:status].eq('active')
  end

  def self.arel_account_credited
    arel_table[:account_credited_id]
  end

  def self.arel_account_debited
    arel_table[:account_debited_id]
  end

  def self.arel_date
    arel_table[:date]
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

  def active?
    status == 'active'
  end
end

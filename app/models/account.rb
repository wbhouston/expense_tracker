# frozen_string_literal: true

class Account < ApplicationRecord
  TYPES = %w(asset expense investment liability revenue)

  TYPE_CREDIT_OR_DEBIT = {
    asset: :debit,
    expense: :debit,
    investment: :debit,
    liability: :credit,
    revenue: :credit,
  }.with_indifferent_access.freeze

  has_many(
    :credit_transactions,
    class_name: Transaction.name,
    foreign_key: :account_credited_id,
  )

  has_many(
    :debit_transactions,
    class_name: Transaction.name,
    foreign_key: :account_debited_id,
  )

  validates(
    :account_type,
    :name,
    :number,
    presence: true,
  )

  validates(
    :name,
    :number,
    uniqueness: { scope: :account_type },
  )

  scope :assets, -> { where(arel_type(eq: 'asset')) }
  scope :expenses, -> { where(arel_type(eq: 'expense')) }
  scope :liabilities, -> { where(arel_type(eq: 'liability')) }
  scope :order_by_number, -> { reorder(:number) }
  scope :revenues, -> { where(arel_type(eq: 'revenue')) }

  def self.arel_type(eq:)
    self.arel_table[:account_type].eq(eq)
  end

  def self.types_for_collection
    TYPES.map { |type| [type.titleize, type] }
  end

  def account_number
    "#{number}"
  end

  def full_label
    "#{number} - #{name}"
  end
end

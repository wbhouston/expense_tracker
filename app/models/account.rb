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

  def self.types_for_collection
    TYPES.map { |type| [type.titleize, type] }
  end

  def account_number
    "#{number}"
  end
end

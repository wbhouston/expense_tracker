# frozen_string_literal: true

class Account < ApplicationRecord
  TYPES = %w(asset expense investment liability revenue)
  CREDIT_OR_DEBIT = %(CR DB)

  validates(
    :name,
    :type,
    :type_number,
    :number,
    :credit_or_debit,
    presence: true,
  )
end

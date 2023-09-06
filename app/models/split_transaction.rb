# frozen_string_literal: true

class SplitTransaction < Transaction
  validates(
    :account_credited,
    :account_debited,
    presence: true
  )
end
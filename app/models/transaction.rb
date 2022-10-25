# frozen_string_literal: e

class Transaction < ApplicationRecord
  belongs_to :account_credited, class_name: 'Account'
  belongs_to :account_debited, class_name: 'Account'

  validates(
    :account_credited,
    :account_debited,
    :date,
    :amount,
    presence: true,
  )
end

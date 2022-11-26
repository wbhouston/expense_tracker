# frozen_string_literal: e

class Transaction < ApplicationRecord
  belongs_to :account_credited, class_name: 'Account', optional: true
  belongs_to :account_debited, class_name: 'Account', optional: true

  validates(:date, :amount, presence: true)
end

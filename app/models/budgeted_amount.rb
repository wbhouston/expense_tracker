#frozen_string_literal: true

class BudgetedAmount < ApplicationRecord
  belongs_to :account

  validates :year, :amount, presence: true
end
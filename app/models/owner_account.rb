# frozen_string_literal: true

class OwnerAccount < ApplicationRecord
  belongs_to :owner, class_name: Owner.name
  belongs_to :account, class_name: Account.name
end

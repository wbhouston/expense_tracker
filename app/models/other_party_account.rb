# frozen_string_literal: true

class OtherPartyAccount < ApplicationRecord
  belongs_to :other_party, class_name: Owner.name
  belongs_to :account, class_name: Account.name
end

# frozen_string_literal: true

class Owner < ApplicationRecord
  has_many(
    :owner_accounts,
    class_name: OwnerAccount.name,
    foreign_key: :owner_id,
  )

  has_many(
    :other_party_accounts,
    class_name: OtherPartyAccount.name,
    foreign_key: :other_party_id,
  )

  validates(:name, presence: true)
end

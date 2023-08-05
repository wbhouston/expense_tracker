class AddOtherPartyAccount < ActiveRecord::Migration[7.0]
  def change
    create_table :other_party_accounts do |t|
      t.references :other_party, null: false, foreign_key: { to_table: :owners }
      t.references :account, foreign_key: { to_table: :accounts }, null: false
    end
  end
end

class AddOwnerAccount < ActiveRecord::Migration[7.0]
  def change
    create_table :owner_accounts do |t|
      t.references :owner, null: false, foreign_key: { to_table: :owners }
      t.references :account, foreign_key: { to_table: :accounts }, null: false
      t.decimal :ownership_percent, precision: 4, scale: 2, null: false
    end
  end
end

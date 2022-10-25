class AddTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.date :date, null: false
      t.references :account_credited, foreign_key: { to_table: :accounts }, null: false
      t.references :account_debited, foreign_key: { to_table: :accounts }, null: false
      t.string :memo
      t.string :note
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.integer :percent_shared
      t.string :imported_transaction_id
    end
  end
end

class AddBudgetedAmountTable < ActiveRecord::Migration[7.0]
  def change
    create_table :budgeted_amounts do |t|
      t.integer :year, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.references :account, null: false
      t.timestamps
    end
  end
end

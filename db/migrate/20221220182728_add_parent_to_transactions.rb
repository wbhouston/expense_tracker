class AddParentToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :parent, null: true, foreign_key: { to_table: :transactions }
  end
end

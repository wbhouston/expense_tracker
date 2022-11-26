class RemoveNullContraintFromTransactionAccountFields < ActiveRecord::Migration[7.0]
  def change
    change_column_null :transactions, :account_credited_id, true
    change_column_null :transactions, :account_debited_id, true
  end
end

class ChangeAccountTypeColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :accounts, :type, :account_type
    remove_column :accounts, :credit_or_debit
    remove_column :accounts, :type_number
  end
end

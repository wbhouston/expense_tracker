class AddAccountsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.string :type_number, null: false
      t.string :number, null: false
      t.string :credit_or_debit, null: false

      t.timestamps
    end
  end
end

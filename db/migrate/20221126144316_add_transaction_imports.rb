class AddTransactionImports < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_imports do |t|
      t.string :name

      t.timestamps
    end
  end
end

class AddMonthToBudgetedAmount < ActiveRecord::Migration[7.0]
  def change
    add_column :budgeted_amounts, :month, :integer, default: 1
  end
end

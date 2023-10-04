class AddFrequencyToBudgetedAmount < ActiveRecord::Migration[7.0]
  def change
    add_column :budgeted_amounts, :frequency, :string, default: :monthly
  end
end

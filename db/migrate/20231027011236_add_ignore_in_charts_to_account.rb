class AddIgnoreInChartsToAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :ignore_in_charts, :boolean, default: false
  end
end

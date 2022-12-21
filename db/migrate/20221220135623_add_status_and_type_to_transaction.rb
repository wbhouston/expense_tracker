class AddStatusAndTypeToTransaction < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :type, :string
    add_column :transactions, :status, :string, default: 'active'
  end
end

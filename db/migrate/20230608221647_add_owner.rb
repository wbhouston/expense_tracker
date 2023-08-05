class AddOwner < ActiveRecord::Migration[7.0]
  def change
    create_table :owners do |t|
      t.string :name
      t.decimal :default_ownership_percent, precision: 4, scale: 2, null: false
    end
  end
end

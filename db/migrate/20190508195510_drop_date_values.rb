class DropDateValues < ActiveRecord::Migration[5.2]
  def change
    drop_table :date_values
  end
end

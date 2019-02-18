class CreateDateValues < ActiveRecord::Migration[5.2]
  def change
    create_table :date_values do |t|
      t.date :date
      t.float :base_value

      t.timestamps
    end
  end
end

class CreateCalendarL3s < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_l3s do |t|
      t.date :date
      t.float :base_value
      t.integer :signed_up_total
      t.text :signed_up_agents, default: [], array: true
      t.float :current_price

      t.timestamps
    end
  end
end

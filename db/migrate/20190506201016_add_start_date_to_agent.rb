class AddStartDateToAgent < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :start_date, :datetime
  end
end

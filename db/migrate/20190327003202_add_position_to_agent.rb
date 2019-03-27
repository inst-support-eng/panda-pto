class AddPositionToAgent < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :position, :string
    add_column :agents, :team, :string
    add_column :agents, :start_time, :string
    add_column :agents, :end_time, :string
    add_column :agents, :work_days, :string
  end
end

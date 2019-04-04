class AddPositionToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :position, :string
    add_column :users, :team, :string
    add_column :users, :start_time, :string
    add_column :users, :end_time, :string
    add_column :users, :work_days, :integer, array: true, default: []
  end
end

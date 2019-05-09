class DropAgents < ActiveRecord::Migration[5.2]
  def change
    drop_table :agents
  end
end

class AddOnPipToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :on_pip, :boolean
  end
end

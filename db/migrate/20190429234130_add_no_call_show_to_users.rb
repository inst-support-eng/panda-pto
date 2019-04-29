class AddNoCallShowToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :no_call_show, :integer
  end
end

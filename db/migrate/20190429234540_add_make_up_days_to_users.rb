class AddMakeUpDaysToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :make_up_days, :integer
  end
end

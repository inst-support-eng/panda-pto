class AddStatusToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :status, :string
  end
end

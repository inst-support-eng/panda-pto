class AddAdminNoteToPtoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :pto_requests, :admin_note, :string
    add_column :pto_requests, :excused, :boolean
  end
end

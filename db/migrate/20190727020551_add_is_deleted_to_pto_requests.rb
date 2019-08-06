class AddIsDeletedToPtoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :pto_requests, :is_deleted, :boolean
  end
end

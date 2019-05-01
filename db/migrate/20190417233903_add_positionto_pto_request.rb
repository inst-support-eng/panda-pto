class AddPositiontoPtoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :pto_requests, :position, :string
  end
end

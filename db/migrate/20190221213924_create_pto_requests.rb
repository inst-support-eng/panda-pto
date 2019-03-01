class CreatePtoRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :pto_requests do |t|
      t.string :reason
      t.date :request_date 
      t.integer :cost # at time of request
      t.integer :signed_up_total # at time of request
      t.integer :user_id
      t.integer :humanity_request_id

      t.timestamps
    end
  end
end

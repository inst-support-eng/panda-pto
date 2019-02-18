class CreateRequestDates < ActiveRecord::Migration[5.2]
  def change
    create_table :request_dates do |t|

      t.timestamps
    end
  end
end

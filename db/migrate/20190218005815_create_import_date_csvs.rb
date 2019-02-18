class CreateImportDateCsvs < ActiveRecord::Migration[5.2]
  def change
    create_table :import_date_csvs do |t|
      t.date :date
      t.float :base_value

      t.timestamps
    end
  end
end

class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.text :message
      t.integer :author
      t.string :recipients, default: [], array: true
      t.string :recipient_numbers, default: [], array: true

      t.timestamps
    end
  end
end

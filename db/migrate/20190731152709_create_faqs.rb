class CreateFaqs < ActiveRecord::Migration[5.2]
  def change
    create_table :faqs do |t|
      t.text :body
      t.string :last_modified_by

      t.timestamps
    end
  end
end

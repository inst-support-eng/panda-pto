class DateValue < ApplicationRecord
  require 'csv'
  validates :date, :base_value, presence: true

  def self.import(file)
    # !TECHDEBT this should be wrapped in some error handling
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
      DateValue.create! row.to_hash
    end
    # delete all duplicate records
    grouped = all.group_by{|x| [x.date]}
    grouped.values.each do |duplicates|
      most_recent = duplicates.pop # pop keeps last item , shift would keep first
      # delete all duplicates
      duplicates.each{|double| double.destroy} # duplicates can now be destroyed
    end
      # push values to calendar table
      # Calendar.create!(self.attribute.except("id", "created_at", "updated_at"))
    # https://stackoverflow.com/questions/28089441/how-can-i-move-data-from-one-table-to-another-in-rails-migration
    # working \o/ ~ish
    DateValue.find_each do |x|
      import = Calendar.find_or_create_by(
        :date => x.date,
        :base_value => x.base_value,
      )
      import.save!
    end

  end
end

